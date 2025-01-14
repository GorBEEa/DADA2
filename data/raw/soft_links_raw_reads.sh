#!/bin/bash

# GorBEEa project 2024

# Bash script to create soft lynks of raw reads to the working directory.

# Usage: ./soft_links_raw_reads.sh /scratch/user/gorbeea_genomic/raw_reads

# Check if a directory was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 /my/original/data/"
    exit 1
fi

DIRECTORY="$1"

# Find all .gz files in the specified directory and create soft links
find "$DIRECTORY" -name "*.gz" | while read -r i; do
    ln -s "$i"
done