#include "ReconfigSched.h"
#include "astra-sim/system/collective/HalvingDoubling.hh"

using namespace AstraSim;


reconfigSched* reconfigSched::m_instance = nullptr;

reconfigSched& reconfigSched::getScheduler()
{
  // not thread safe
  if (m_instance == nullptr)
  {
    m_instance = new reconfigSched();
  }
  return *m_instance;
}


reconfigSched::reconfigSched()
  :  m_ocs (nullptr), m_bandwidthBps (0), m_isDemandAware(false)
{}

reconfigSched::~reconfigSched(){
    m_ocs->Unref(); //decrease ref count, which is incremented on assignement during SetupNetwork()
}

void
reconfigSched::setOCSNode(OCSNode* ocs)
{
  m_ocs = ocs;
}

void
reconfigSched::setBandwidth(uint64_t bps)
{
  m_bandwidthBps = bps;
}

void
reconfigSched::setMatchings(const Algorithm* algo, int rootNodeId)
{
    if (algo->name == Algorithm::Name::HalvingDoubling){
        const HalvingDoubling* hd = dynamic_cast<const HalvingDoubling*>(algo);
        if (hd == nullptr) {
            printf("ReconfigSched: Collective Communication Algorithm Name and Typ mismatch. Something is wrong.");
            exit(-707);
        }

        // check if this really applies for all ComTypes in HalvingDoubling
        // its source code suggests it doesn't always create pairs like this

        int num = (int) hd->nodes_in_ring;
        int R = reconfigSched::ceil_log2(num);
        int maxRounds = (hd->comType == ComType::All_Reduce) ? R * 2 : R;


        if ( !( (1u << R) == num) ){
            // further calculations are based on assumption of nodeNum == 2^roundNum
            printf("ReconfigSched: Number of nodes is not a power of 2.");
        }

        // important assumption: For all ports at OCS: portNum == connected NodeId and NodeId \in {0,1,...,n-1} continuous
        // TODO check/verify this assumption before continuing

        uint64_t dist = 0;
        int logicalSrc, logicalDst;
        bool clockwiseDirection;
        for (int curRound = 0; curRound < maxRounds; curRound++){
            dist = reconfigSched::halvingDoublingDist(curRound, num, hd->comType);
            for (int src = 0; src < num; src++){
                clockwiseDirection = ( src == 0 || (src / dist) % 2 == 0 );
                logicalSrc = (src - rootNodeId + num) % num; //shifting by rootNodeId
                if (clockwiseDirection){
                    logicalDst = (logicalSrc + dist) % num;
                }
                else{ //counter clockwise
                    logicalDst = (logicalSrc + num - dist ) % num;
                }
                m_allRoundsPortMaps[curRound][static_cast<uint32_t>(src)] = ((logicalDst + rootNodeId) % num);
            }
        }
    }
    else{
        //TODO implement other algos
    }
}

void 
reconfigSched::setDaMode(bool isDemandAware)
{
    m_isDemandAware = isDemandAware;
}

bool 
reconfigSched::getDaMode()
{
    return m_isDemandAware;
}

const std::map<uint32_t, uint32_t>
reconfigSched::roundToPortMap(int round)
{
  auto it = m_allRoundsPortMaps.find(round);
  if (it == m_allRoundsPortMaps.end ())
  {
    printf("Demand-Aware Reconfig: No portmap found for round %d", round);
    return std::map<uint32_t, uint32_t>();
  }
  else
  {
    return it->second;
  }
}

bool
reconfigSched::reconfig (const Algorithm* algo, int roundNum, uint64_t messageSize)
{
  int64_t rDelayNs = getReconfigDelay();

// TODO ensure messagesize in bits, or convert to bits; bandwdith is in bps.
  //if (rDelayNs < (m_bandwidthBps * messageSize) * (calcCongestionFactor(algo, roundNum) - 1)){
  if (true){ //testing
    if (m_allRoundsPortMaps.size() == 0)
    {
        setMatchings(algo,0); // unsure if rootNodeId ever changes
    }
    m_ocs->Reconfigure(roundToPortMap(roundNum));
    // the callee has to ensure to wait until reconfiguration is done, until starting transmission
    // we don't do any blocking here
    return true;
  }

  return false;
}

// returns the delay in nanoseconds
int64_t
reconfigSched::getReconfigDelay()
{
  return m_ocs->GetReconfigDelay().GetNanoSeconds();
}

float
reconfigSched::calcCongestionFactor(const Algorithm* algo, int roundNum)
{
  const HalvingDoubling* hd = dynamic_cast<const HalvingDoubling*>(algo);
  if (hd != nullptr){
    return halvingDoublingDist(roundNum,hd->nodes_in_ring,hd->comType); // distance == oversubscription in halving doubling
  }
  // algorithm-specific congestion logic
  return 0.0f;
}

// Compute the hop distance for round `r` in a halving/doubling
// over `n` nodes for the given collective `type`.
uint64_t
reconfigSched::halvingDoublingDist(int round, int nodes, AstraSim::ComType type)
{
    int R = reconfigSched::ceil_log2(nodes);

    switch (type) {
      case ComType::All_Reduce:
        // rounds 0..R-1: hops = 1,2,4,…   rounds R..2R-1: hops = 2^(2R−r−1),…
        if (round < R) {
          return 1ull << round; 
        } else {
          return 1ull << (2*R - round - 1);
        }

      case ComType::Reduce_Scatter:
        // just the first R doubling hops: 1,2,4,…,2^(R-1)
        return 1ull << round;

      case ComType::All_Gather:
        // start at n/2, then n/4, …, n/(2^R)
        return uint64_t(nodes) >> round;

      default:
        printf("ReconfigSched: Unknown Communication Type in halvingDoublingDist");
        return 0;
    }
}

int reconfigSched::ceil_log2(uint64_t x){
    int r = 0;
    --x; // 2<0 == 1 for r=0

    // 2^r < x
    while( (1u << r) < x){ 
        r++;
    }

    return r;
}
