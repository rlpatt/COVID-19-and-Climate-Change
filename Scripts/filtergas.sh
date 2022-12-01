#!/bin/bash

##################################################
# Author: Saurav Kiri
# Date: 2022-11-27
# Description: Filters the NOAA gas datasets for data only from 2003 - present
# Requires: AWK text stream parsing program
# Arguments:
    # 1) Directory of NOAA gas files
# Usage: bash parsetemp.sh <filename>
##################################################

# Get dir from argument
FILEDIR=${1}

# Isolate the names of the files without extension (prefixes)
prefix=$(ls | sed -r "s/[.]txt//"); 

# For each file name, filter to keep only data 2003 - present
for name in ${prefix} 
do 
    awk '{if ($1 > 2002) print $0}' "${name}.txt" > "${name}-filtered.txt" 
done