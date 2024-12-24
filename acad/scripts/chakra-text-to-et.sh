#!/bin/bash
set -e

## ******************************************************************************
## This source code is licensed under the MIT license found in the
## LICENSE file in the root directory of this source tree.
##
## Copyright (c) 2024 Georgia Institute of Technology
## ******************************************************************************

# find the absolute path to this script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_DIR="${SCRIPT_DIR:?}/../.."
TXT_DIR="${PROJECT_DIR:?}/acad/text-workloads"
ET_DIR="${PROJECT_DIR:?}/acad/et-workloads"
TARGET_WORKLOAD=$1
NUM_NPUS=$2
NUM_PASSES=$3

# Install Chakra
echo "[ASTRA-sim] Installing Chakra..."
echo ""
if [[ $(which chakra_converter) == "" ]]; then
    echo "Chakra not found. Installing Chakra..."
    "${PROJECT_DIR:?}"/utils/install_chakra.sh
fi

echo ""
echo "[ASTRA-sim] Chakra installation done."

# Run text-to-chakra converter
echo "[ASTRA-sim] Running Text-to-Chakra converter..."
echo ""

# check if $ET_DIR exists and create the directory if not
if [ ! -d "${ET_DIR:?}" ]; then
    mkdir -p "${ET_DIR:?}"
fi

chakra_converter Text \
    --input="${TXT_DIR:?}/${TARGET_WORKLOAD:?}.txt" \
    --output="${ET_DIR:?}/${TARGET_WORKLOAD:?}" \
    --num-npus=${NUM_NPUS} \
    --num-passes=${NUM_PASSES}

echo ""
echo "[ASTRA-sim] Text-to-Chakra conversion done."