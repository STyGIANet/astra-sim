#!/bin/bash
ulimit -n 100000
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(realpath "${SCRIPT_DIR:?}/../..")
TXT_WORKLOAD_DIR="${PROJECT_DIR:?}/acad/text-workloads"
ET_WORKLOAD_DIR="${PROJECT_DIR:?}/acad/et-workloads"
LOGICAL_TOPO_DIR="${PROJECT_DIR:?}/acad/logical-topo-configs"
NETWORK_DIR="${PROJECT_DIR:?}/acad/network-configs"
MEMORY_DIR="${PROJECT_DIR:?}/acad/memory-configs"
SYSTEM_DIR="${PROJECT_DIR:?}/acad/system-configs"
NETWORK_TOPO_DIR="${PROJECT_DIR:?}/acad/network-topologies"
RESULTS_DIR="${PROJECT_DIR:?}/acad/results"
BASE_CONFIG_DIR="${PROJECT_DIR:?}/acad/base-configs"
NS3_DIR=$(realpath "${SCRIPT_DIR:?}"/../..)/extern/network_backend/ns-3

if [[ ! -d $TXT_WORKLOAD_DIR ]]; then
	mkdir -p $TXT_WORKLOAD_DIR
fi
if [[ ! -d $ET_WORKLOAD_DIR ]]; then
	mkdir -p $ET_WORKLOAD_DIR
fi
if [[ ! -d $LOGICAL_TOPO_DIR ]]; then
	mkdir -p $LOGICAL_TOPO_DIR
fi
if [[ ! -d $NETWORK_DIR ]]; then
	mkdir -p $NETWORK_DIR
fi
if [[ ! -d $MEMORY_DIR ]]; then
	mkdir -p $MEMORY_DIR
fi
if [[ ! -d $SYSTEM_DIR ]]; then
	mkdir -p $SYSTEM_DIR
fi
if [[ ! -d $NETWORK_TOPO_DIR ]]; then
	mkdir -p $NETWORK_TOPO_DIR
fi
if [[ ! -d $RESULTS_DIR ]]; then
	mkdir -p $RESULTS_DIR
fi

cd $PROJECT_DIR
if [ -f ".venv/bin/activate" ]; then
	export VIRTUAL_ENV_DISABLE_PROMPT=1
	source .venv/bin/activate && export PS1='[$(realpath --relative-to="$PROJECT_DIR" "$PWD")] astra-sim> '
fi

if [ -f "$HOME/.protocPaths" ]; then
	source ~/.protocPaths
fi

cd -