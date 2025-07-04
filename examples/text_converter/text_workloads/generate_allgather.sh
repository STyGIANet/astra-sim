#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <Bytes> <NumNPUs>"
  exit 1
fi

BYTES=$1
NPUS=$2

# File and directory names
INPUT_FILE="microAllGather${BYTES}B.txt"
OUTPUT_DIR="AllGather${BYTES}B_${NPUS}"
OUTPUT_PATH="${OUTPUT_DIR}/AllGather${BYTES}B_${NPUS}"

# Create input text file
cat <<EOF > "$INPUT_FILE"
MICRO
1
conv1 -1 5 NONE 0 5 NONE 0 5  ALLGATHER ${BYTES} 5
EOF

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run the chakra_converter command
chakra_converter Text \
  --input="./$INPUT_FILE" \
  --output="./$OUTPUT_PATH" \
  --num-npus="$NPUS" \
  --num-passes=1

