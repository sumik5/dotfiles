#!/bin/bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'

usage() {
    echo "Usage: $(basename "$0") <directory>"
    echo "  Recursively removes all .srt files under the specified directory."
}

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No directory specified.${NO_COLOR}"
    usage
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "${TARGET_DIR}" ]; then
    echo -e "${RED}Error: '${TARGET_DIR}' is not a directory or does not exist.${NO_COLOR}"
    usage
    exit 1
fi

# Find all .srt files
mapfile -t srt_files < <(find "${TARGET_DIR}" -type f -name "*.srt")
count=${#srt_files[@]}

if [ "${count}" -eq 0 ]; then
    echo -e "${YELLOW}No .srt files found under '${TARGET_DIR}'.${NO_COLOR}"
    exit 0
fi

echo -e "${YELLOW}Found ${count} .srt file(s) under '${TARGET_DIR}':${NO_COLOR}"
for f in "${srt_files[@]}"; do
    echo "  ${f}"
done

echo ""
read -r -p "Delete all ${count} file(s)? [y/N] " answer

if [[ "${answer}" =~ ^[Yy]$ ]]; then
    for f in "${srt_files[@]}"; do
        rm -f "${f}"
    done
    echo -e "${GREEN}Deleted ${count} .srt file(s).${NO_COLOR}"
else
    echo "Aborted."
    exit 0
fi
