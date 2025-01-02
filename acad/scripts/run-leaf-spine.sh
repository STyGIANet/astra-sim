#!/bin/bash

# find the absolute path to this script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_DIR="${SCRIPT_DIR:?}/../.."
TXT_WORKLOAD_DIR="${PROJECT_DIR:?}/acad/text-workloads"
ET_WORKLOAD_DIR="${PROJECT_DIR:?}/acad/et-workloads"
LOGICAL_TOPO_DIR="${PROJECT_DIR:?}/acad/logical-topo-configs"
NETWORK_DIR="${PROJECT_DIR:?}/acad/network-configs"
MEMORY_DIR="${PROJECT_DIR:?}/acad/memory-configs"
SYSTEM_DIR="${PROJECT_DIR:?}/acad/system-configs"
NETWORK_TOPO_DIR="${PROJECT_DIR:?}/acad/network-topologies"
RESULTS_DIR="${PROJECT_DIR:?}/acad/results"
NS3_DIR="${SCRIPT_DIR:?}"/../../extern/network_backend/ns-3

NODES=(256)
MSG_SIZES=(1048576 2097152 4194304 8388608 16777216)
TXT_WORKLOADS=("DLRM_HybridParallel" "Resnet50_DataParallel" "MLP_HybridParallel_Data_Model")
ALLREDUCE_ALGS=("direct" "halvingDoubling" "ring" "doubleBinaryTree")
APP_LOADBALANCE_ALGS=("ethereal" "mp-rdma-2" "mp-rdma-4" "mp-rdma-8" "none")
ROUTING_ALGS=("SOURCE_ROUTING" "REPS" "END_HOST_SPRAY")

ALGS=("ethereal" "mp-rdma-2" "mp-rdma-4" "mp-rdma-8" "reps" "spray")

# Recompile ns3
# cd ${SCRIPT_DIR}
# ./build.sh -l
# ./build.sh -c
##############################################################################
# leaf-spine topology with 256 nodes
# Allreduce across various message sizes and load balancing algorithms
N=0
NUM_NODES=256
for MSG_SIZE in ${MSG_SIZES[@]};do
	
	for ALG in ${ALGS[@]};do
	
		if [[ $ALG == "ethereal" ]];then
			ROUTING="SOURCE_ROUTING"
			APP_LOADBALANCE_ALG="ethereal"
		elif [[ $ALG == "mp-rdma-2" ]];then
			ROUTING="ECMP"
			APP_LOADBALANCE_ALG="mp-rdma"
		elif [[ $ALG == "mp-rdma-4" ]];then
			ROUTING="ECMP"
			APP_LOADBALANCE_ALG="mp-rdma"
		elif [[ $ALG == "mp-rdma-8" ]];then
			ROUTING="ECMP"
			APP_LOADBALANCE_ALG="mp-rdma"
		elif [[ $ALG == "reps" ]];then
			ROUTING="REPS"
			APP_LOADBALANCE_ALG="none"
		elif [[ $ALG == "spray" ]];then
			ROUTING="END_HOST_SPRAY"
			APP_LOADBALANCE_ALG="none"
		fi

		for ALLREDUCE_ALG in ${ALLREDUCE_ALGS};do

			WORKLOAD=$(realpath ${ET_WORKLOAD_DIR}/AllReduce-$NUM_NODES-$MSG_SIZE-leaf-spine)
			SYSTEM=$(realpath ${SYSTEM_DIR}/system-$ALLREDUCE_ALG-$APP_LOADBALANCE_ALG.json)
			NETWORK=$(realpath ${NETWORK_DIR}/config-leaf-spine-${NUM_NODES}-${ROUTING}-${APP_LOADBALANCE_ALG}-${ALLREDUCE_ALG}-${MSG_SIZE}.txt)
			MEMORY=$(realpath ${MEMORY_DIR}/remote_memory.json)
			LOGICAL_TOPOLOGY=$(realpath ${LOGICAL_TOPO_DIR}/logical-topo-$NUM_NODES.json)

			# time ("${NS3_DIR}"/build/scratch/ns3.42-AstraSimNetwork-default \
			#         --workload-configuration=${WORKLOAD} \
			#         --system-configuration=${SYSTEM} \
			#         --network-configuration=${NETWORK} \
			#         --remote-memory-configuration=${MEMORY} \
			#         --logical-topology-configuration=${LOGICAL_TOPOLOGY} \
			#         --comm-group-configuration=\"empty\")

			echo "$NETWORK"
			N=$(( $N+1 ))
		done
	done
done
#################################################################################
# leaf-spine topology with 256 nodes
# Various workloads and load balancing algorithms
NUM_NODES=256
for TXT_WORKLOAD in ${TXT_WORKLOADS[@]};do
	
	for ALG in ${ALGS[@]};do
	
		if [[ $ALG == "ethereal" ]];then
			ROUTING="SOURCE_ROUTING"
			APP_LOADBALANCE_ALG="ethereal"
		elif [[ $ALG == "mp-rdma-2" ]];then
			ROUTING="ECMP"
			APP_LOADBALANCE_ALG="mp-rdma"
		elif [[ $ALG == "mp-rdma-4" ]];then
			ROUTING="ECMP"
			APP_LOADBALANCE_ALG="mp-rdma"
		elif [[ $ALG == "mp-rdma-8" ]];then
			ROUTING="ECMP"
			APP_LOADBALANCE_ALG="mp-rdma"
		elif [[ $ALG == "reps" ]];then
			ROUTING="REPS"
			APP_LOADBALANCE_ALG="none"
		elif [[ $ALG == "spray" ]];then
			ROUTING="END_HOST_SPRAY"
			APP_LOADBALANCE_ALG="none"
		fi

		for ALLREDUCE_ALG in ${ALLREDUCE_ALGS};do

			WORKLOAD=$(realpath ${ET_WORKLOAD_DIR}/$TXT_WORKLOAD-$NUM_NODES-leaf-spine)
			SYSTEM=$(realpath ${SYSTEM_DIR}/system-$ALLREDUCE_ALG-$APP_LOADBALANCE_ALG.json)
			NETWORK=$(realpath ${NETWORK_DIR}/config-leaf-spine-${NUM_NODES}-${ROUTING}-${APP_LOADBALANCE_ALG}-${ALLREDUCE_ALG}-${TXT_WORKLOAD}.txt)
			MEMORY=$(realpath ${MEMORY_DIR}/remote_memory.json)
			LOGICAL_TOPOLOGY=$(realpath ${LOGICAL_TOPO_DIR}/logical-topo-$NUM_NODES.json)

			# "${NS3_DIR}"/build/scratch/ns3.42-AstraSimNetwork-default \
			#         --workload-configuration=${WORKLOAD} \
			#         --system-configuration=${SYSTEM} \
			#         --network-configuration=${NETWORK} \
			#         --remote-memory-configuration=${MEMORY} \
			#         --logical-topology-configuration=${LOGICAL_TOPOLOGY} \
			#         --comm-group-configuration=\"empty\"

			echo "$NETWORK"
			N=$(( $N+1 ))
		done
	done
done

echo "Total $N experiments..."