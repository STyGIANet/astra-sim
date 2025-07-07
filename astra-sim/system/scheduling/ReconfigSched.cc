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
  :  m_ocs (nullptr), m_bandwidthBps (0), m_isDemandAware(false), m_syncRoundsSeen(0)
{}

reconfigSched::~reconfigSched(){
    m_ocs->Unref(); //decrease ref count, which is incremented on assignement during SetupNetwork()
}

void
reconfigSched::setReconfigDecisionPerRound(const std::vector<bool>& shouldReconfig)
{
  m_shouldReconfig = shouldReconfig;
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

bool reconfigSched::sync(Algorithm* algo)
{
  // we only support HalvingDoubling for now
  const HalvingDoubling* hd = dynamic_cast<const HalvingDoubling*>(algo);
  NS_ASSERT_MSG(hd, "sync() only works on HalvingDoubling");

  // register
  m_algos.push_back(algo);
  m_syncRoundsSeen++;

  // once we've seen all ranks, fire exactly N SyncBarrier events
  if (m_syncRoundsSeen >= hd->nodes_in_ring) {
      for (auto* a : m_algos) {
          int64_t syncInNS = 0;
          int curRound = hd->total_rounds - hd->stream_count;
          if (m_isDemandAware && curRound < m_shouldReconfig.size()){
            if(curRound < 0){
              printf("ReconfigSched detected negative current round number.\n");
              exit(-706);
            }
            if(m_shouldReconfig[curRound] == true){
              printf("%d: RECONFIGURING ACCORDING TO SCHEDULLLEEEEE", ns3::Simulator::Now().GetTimeStep());
              fflush(stdout);
              syncInNS = reconfigure(hd,curRound);
            }
          }

          ns3::Simulator::Schedule(ns3::NanoSeconds(syncInNS), [a]() {
              a->run(EventType::SyncBarrier, nullptr);
          });
      }

      // reset for next round
      m_syncRoundsSeen = 0;
      m_algos.clear();
      return true;
  }
  return false;
}

void
reconfigSched::setMatchings(const Algorithm* algo, int rootNodeId)
{
    if (algo->name == Algorithm::Name::HalvingDoubling){
        const HalvingDoubling* hd = dynamic_cast<const HalvingDoubling*>(algo);
        if (hd == nullptr) {
            printf("ReconfigSched: Algorithm Name/Type mismatch.\n");
            exit(-707);
        }

        int N = static_cast<int>(hd->nodes_in_ring);
        int R = ceil_log2(N);
        int maxRounds = hd->total_rounds;

        if ((1u << R) != N) {
            printf("ReconfigSched: Number of nodes (%d) is not a power of 2.\n", N);
            exit(-708);
        }

        for (int curRound = 0; curRound < maxRounds; ++curRound) {
            uint64_t dist = halvingDoublingDist(curRound, N, hd->comType);

            for (int src = 0; src < N; ++src) {
                // Determine communication partner
                bool clockwise = (src == 0 || (src / dist) % 2 == 0);
                int logicalSrc = (src - rootNodeId + N) % N;
                int logicalDst;

                if (clockwise) {
                    logicalDst = (logicalSrc + dist) % N;
                } else {
                    logicalDst = (logicalSrc + N - dist) % N;
                }

                int realSrc = (logicalSrc + rootNodeId) % N;
                int realDst = (logicalDst + rootNodeId) % N;

                uint32_t src_tx_port = realSrc;
                uint32_t src_rx_port = realSrc + N;
                uint32_t dst_tx_port = realDst;
                uint32_t dst_rx_port = realDst + N;

                // Bidirectional mappings for this round
                m_allRoundsPortMaps[curRound][src_tx_port] = dst_rx_port;
                m_allRoundsPortMaps[curRound][dst_rx_port] = src_tx_port;
                m_allRoundsPortMaps[curRound][src_rx_port] = dst_tx_port;
                m_allRoundsPortMaps[curRound][dst_tx_port] = src_rx_port;
            }
        }
    } else {
        printf("ReconfigSched: Algorithm not supported in setMatchings().\n");
        exit(-709);
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

int64_t
reconfigSched::reconfigure(const Algorithm* algo, int roundNum)
{
    int64_t rDelayNs = getReconfigDelay();
    if (m_allRoundsPortMaps.size() == 0)
    {
        setMatchings(algo,0); // unsure if rootNodeId ever changes
    }
    m_ocs->Reconfigure(roundToPortMap(roundNum));

  return rDelayNs;
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
        return uint64_t(nodes) >> (round+1);

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
