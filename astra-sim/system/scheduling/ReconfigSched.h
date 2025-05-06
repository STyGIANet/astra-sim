#ifndef __RECONFIG_SCHED_HH__
#define __RECONFIG_SCHED_HH__

#include <cstdint>
#include <map>
#include "ns3/ocs-node.h"
#include "astra-sim/system/collective/Algorithm.hh"

namespace AstraSim {

using ns3::OCSNode;

class reconfigSched {
    public:
        // singleton, access the one-and-only scheduler
        // this singleton implementatin is not yet thread-safe
        static reconfigSched& getScheduler();

        // helper functions for calculations of distance between communication pairs
        static int ceil_log2(uint64_t x);
        static uint64_t halvingDoublingDist(int round, int nodes, AstraSim::ComType type);

        // Public API
        void setOCSNode (OCSNode* ocs);
        void setBandwidth (uint64_t bps);
        void setMatchings (const Algorithm* algo, int rootNodeId); // sets map with the communication pattern - matching - for all rounds. Used as portMapping for OCS, iff reconfigDecision == true for that round


        /* bool isReconfig(int roundNum)
        / requires data:
        /   - reconfigDelay: configured via topology file and attribute of OCS 
        /   - bandwidth: assuming uniform link bandwidth, Vamsi mentioned the model uses source interface bandwidth anyway.
        /   - congestion factor: algorithm-specific, refers to the factor of oversupscription in the most congested link in this face
        /
        / Returns the decision and instructs the OCS to reconfigure to required portMap
        / -> if yes reconfigure, then the algorithm needs the reconfigDelay to wait that amount of time
        / if no -> just continue. 
        */
        bool reconfig(const Algorithm* algo, int roundNum, uint64_t messageSize);
        int64_t getReconfigDelay (); // set in ocs node. Is called by algo so it knows when to schedule send to continue to next round after reconfig

    private: 
        // hidden as singleton
        reconfigSched();
        ~reconfigSched() = default;

        // for now, switch case on the type of algorithm (class implementing the Algorithm interface), and return value calculated based on round for that specific type.
        // for the later generalized method we'll still need the algorithm and round info as inputs
        float calcCongestionFactor(const Algorithm* algo, int roundNum); 
    
        const std::map<uint32_t, uint32_t> roundToPortMap (int round);

        // data members
        static reconfigSched*                   m_instance; // singleton, there's only one instance of a reconfiguration Scheduler
        OCSNode*                                m_ocs; // reconfigSched controls the reconfiguration of exactly one OCS node. So we can get reconfigDelay directly from this, also to instruct OCS to reconfigure
        uint64_t                                m_bandwidthBps; // (uniform) link bandwidth in network topology, used for reconfigDecision. Set explicitely during SetupNetwork
        std::map<int, std::map<uint32_t, uint32_t>>     m_allRoundsPortMaps;     //assosciates the rounds of a coll. comm. algorithm with the node-to-node communication pair - which is a matching and hence a port mapping of our ocs
                                                    // for now we assume we're always operating with the same algo, later for multidimensional or 
};

}  // namespace AstraSim

#endif /* __RECONFIG_SCHED_HH__ */