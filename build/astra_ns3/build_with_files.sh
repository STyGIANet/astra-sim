#!/bin/bash
set -e

# Get absolute path of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ASTRA_SIM_DIR="${SCRIPT_DIR}/../../astra-sim"
NS3_DIR="${SCRIPT_DIR}/../../extern/network_backend/ns-3"
SYSTEM="${SCRIPT_DIR}/../../examples/ns3/system.json"
MEMORY="${SCRIPT_DIR}/../../examples/ns3/remote_memory.json"

# Parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --workload)
      WORKLOAD="$2"
      shift 2
      ;;
    --logical-topology)
      LOGICAL_TOPOLOGY="$2"
      shift 2
      ;;
    --network)
      NETWORK="$2"
      shift 2
      ;;
    -r|--run|-c|--compile|-d|--debug|-l|--clean|-lr|--clean-result|-h|--help)
      CMD="$1"
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

# Validate required inputs
if [[ -z "$WORKLOAD" || -z "$LOGICAL_TOPOLOGY" || -z "$NETWORK" ]]; then
  echo "Error: Missing required arguments."
  echo "Usage: $0 --workload <path> --logical-topology <path> --network <path> [-r|-c|-d|-l|-lr|-h]"
  exit 1
fi

#echo "Received Workload: $WORKLOAD"
#echo ""
#echo "Received logical topology: $LOGICAL_TOPOLOGY"
#echo ""
#echo "Received network $NETWORK"
#echo ""

# Functions
function setup {
    protoc et_def.proto \
        --proto_path "${SCRIPT_DIR}/../../extern/graph_frontend/chakra/schema/protobuf/" \
        --cpp_out "${SCRIPT_DIR}/../../extern/graph_frontend/chakra/schema/protobuf/"
}

function compile {
    cd "${NS3_DIR}"
    ./ns3 configure --enable-mpi
    ./ns3 build AstraSimNetwork -j 12
    cd "${SCRIPT_DIR}"
}

function run {
    cd "${NS3_DIR}/build/scratch"
    ./ns3.42-AstraSimNetwork-default \
        --workload-configuration="${WORKLOAD}" \
        --system-configuration="${SYSTEM}" \
        --network-configuration="${NETWORK}" \
        --remote-memory-configuration="${MEMORY}" \
        --logical-topology-configuration="${LOGICAL_TOPOLOGY}" \
        --comm-group-configuration="empty"
    cd "${SCRIPT_DIR}"
}

function cleanup {
    cd "${NS3_DIR}"
    ./ns3 distclean
    cd "${SCRIPT_DIR}"
}

function cleanup_result {
    echo "Cleaning up results not implemented."
}

function debug {
    cd "${NS3_DIR}"
    ./ns3 configure --enable-mpi --build-profile debug
    ./ns3 build AstraSimNetwork -j 12 -v
    cd "${NS3_DIR}/build/scratch"
    gdb --args "${NS3_DIR}/build/scratch/ns3.42-AstraSimNetwork-debug" \
        --workload-configuration="${WORKLOAD}" \
        --system-configuration="${SYSTEM}" \
        --network-configuration="${NETWORK}" \
        --remote-memory-configuration="${MEMORY}" \
        --logical-topology-configuration="${LOGICAL_TOPOLOGY}" \
        --comm-group-configuration="empty"
}

function special_debug {
    cd "${NS3_DIR}/build/scratch"
    valgrind --leak-check=yes "${NS3_DIR}/build/scratch/ns3.42-AstraSimNetwork-default" \
        --workload-configuration="${WORKLOAD}" \
        --system-configuration="${SYSTEM}" \
        --network-configuration="${NETWORK}" \
        --remote-memory-configuration="${MEMORY}" \
        --logical-topology-configuration="${LOGICAL_TOPOLOGY}" \
        --comm-group-configuration="empty"
}

# Main Script
case "$CMD" in
-l|--clean)
    cleanup;;
-lr|--clean-result)
    cleanup
    cleanup_result;;
-d|--debug)
    setup
    debug;;
-c|--compile|"")
    setup
    compile;;
-r|--run)
    run;;
-h|--help|*)
    echo "Usage:"
    echo "  $0 --workload <file> --logical-topology <file> --network <file> [--run|--compile|--debug|--clean|--clean-result]"
    ;;
esac

