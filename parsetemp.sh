#!/bin/bash

##################################################
# Author: Saurav Kiri
# Date: 2022-11-28
# Description: Parses the NASA GISTEMP csv to isolate individual datasets.
# Requires: AWK text stream parsing program
# Arguments:
    # 1) Directory of file
    # 2) Filename
# Usage: bash parsetemp.sh <<filename>
##################################################

# Get dir + filename from argument
FILEDIR=${1}
FILENAME=${2}

cd ${FILEDIR}
echo -e "The current directory is: ${PWD}\n"

# Code taken from https://stackoverflow.com/questions/1825745/
awk '/Global.*/{n++}{print > "nasa_gistemp_" n ".csv"}' ${FILENAME}
