#!/bin/bash

# GorBEEa project 2024

# Bash script to generate a tab delimited txt file with the correct relation of different names used.
# It need two text files, the first with the original ID and the new or final ID and, the second with the original ID and the intermediate sample name.
# It provides an output file of three columns in the following order: 1) ID_renamed, 2) ID_random, 3) ID_original.

# Usage: ./name_codification_2023_GorBEEa.sh ID_original.txt ID_random.txt

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 ID_original.txt ID_random.txt"
    exit 1
fi

# Arguments
FILE1="$1"
FILE2="$2"

# Extract columns from files, skip headers, and sort by ID_original
tail -n +2 ${FILE1} | cut -f1,2 | sort -t$'\t' -k1,1 > sorted1.txt
tail -n +2 ${FILE2} | cut -f1,2 | sort -t$'\t' -k1,1 > sorted2.txt

# Join the sorted files based on ID_original
join -t$'\t' -1 1 -2 1 sorted1.txt sorted2.txt > joined_IDs_temp1.txt

# Reorder
awk 'BEGIN {OFS="\t"} {print $2, $3, $1}' joined_IDs_temp1.txt > joined_IDs_temp2.txt

# Remove strange characters
tr -d '\r' <joined_IDs_temp2.txt > joined_IDs_temp3.txt

# Add headers
sed $'1s/^/ID_renamed\tID_random\tID_original\\\n&/' joined_IDs_temp3.txt > joined_IDs.txt

# The output file 'joined_IDs.txt' will contain ID_renamed, ID_random, ID_original

# Clean up intermediate files
rm joined_IDs_temp*.txt sorted1.txt sorted2.txt

echo "joined_IDs.txt file created successfully."