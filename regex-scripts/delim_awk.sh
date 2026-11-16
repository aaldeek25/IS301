#!/bin/bash
# Name: Ahmed Aldeek
# Script: delim_awk.sh (idea 2, awk version)
#
# Purpose: Replace every match of a delimiter pattern (a regex) with a
#          replacement delimiter, on every input line.
#
# Usage:   ./delim_awk.sh PATTERN [REPLACEMENT] < input.txt
#          ./delim_awk.sh '[[:space:]:]+' ', ' < people.txt
#          cat people.txt | ./delim_awk.sh '[[:space:]:]+'
#
# Input:   PATTERN is required: an extended regex such as '[[:space:]:]+'
#          (whitespace or colon). REPLACEMENT is optional and defaults to ", ".
#          Text lines come from standard input.
# Output:  Every input line, with all matches of PATTERN replaced, on
#          standard output. Usage errors go to standard error.
# Note:    In REPLACEMENT, & stands for the matched text.
# Exit:    0 on success, 2 if the script was used incorrectly.

# Require the PATTERN argument.
if [ $# -lt 1 ]; then
  echo "Usage: $0 PATTERN [REPLACEMENT] < input.txt" >&2
  exit 2
fi

pattern="$1"
replacement="${2:-, }"   # default replacement is a comma and a space

# Pass the values through the environment so awk does not rewrite backslashes
# (as it would with -v). gsub replaces all matches on the current line ($0),
# then print writes the line to standard output.
PAT="$pattern" REP="$replacement" awk '{ gsub(ENVIRON["PAT"], ENVIRON["REP"]); print }'
