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

NODES=(256)
MSG_SIZES=(1048576 2097152 4194304 8388608 16777216)
TXT_WORKLOADS=("DLRM_HybridParallel" "Resnet50_DataParallel" "MLP_HybridParallel_Data_Model")
ALLREDUCE_ALGS=("direct" "halvingDoubling" "ring" "doubleBinaryTree")
APP_LOADBALANCE_ALGS=("ethereal" "mp-rdma-2" "mp-rdma-4" "mp-rdma-8" "none")
ROUTING_ALGS=("SOURCE_ROUTING" "REPS" "END_HOST_SPRAY")

ALGS=("ethereal" "mp-rdma-2" "mp-rdma-4" "mp-rdma-8" "reps" "spray")


######################################################################################
# fat-tree topology k=32 with 8192 nodes
# AllReduce with various message sizes and load balancing algorithms
N=0
NUM_NODES=8192
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

			echo "$ALG $MSG_SIZE $APP_LOADBALANCE_ALG $ROUTING $ALLREDUCE_ALG $NUM_NODES"
			N=$(( $N+1 ))

		done
	done
done
#################################################################################
# fat-tree topology k=32 with 8192 nodes
# Various workloads and load balancing algorithms
NUM_NODES=8192
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

			echo "$ALG $TXT_WORKLOAD $APP_LOADBALANCE_ALG $ROUTING $ALLREDUCE_ALG $NUM_NODES"
			N=$(( $N+1 ))

		done
	done
done

echo "Total $N experiments..."