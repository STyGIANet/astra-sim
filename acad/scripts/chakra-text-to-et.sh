#!/bin/bash
set -e

## ******************************************************************************
## This source code is licensed under the MIT license found in the
## LICENSE file in the root directory of this source tree.
##
## Copyright (c) 2024 Georgia Institute of Technology
## ******************************************************************************

# find the absolute path to this script
source config.sh

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

chakra_converter Text \
    --input="${TXT_WORKLOAD_DIR:?}/${TARGET_WORKLOAD:?}.txt" \
    --output="${ET_WORKLOAD_DIR:?}/${TARGET_WORKLOAD:?}" \
    --num-npus=${NUM_NPUS} \
    --num-passes=${NUM_PASSES}

echo ""
echo "[ASTRA-sim] Text-to-Chakra conversion done."