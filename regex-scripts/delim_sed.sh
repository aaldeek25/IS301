#!/bin/bash
# Name: Ahmed Aldeek
# Script: delim_sed.sh (idea 2, sed version)
#
# Purpose: Replace every match of a delimiter pattern (a regex) with a
#          replacement delimiter, on every input line.
#
# Usage:   ./delim_sed.sh PATTERN [REPLACEMENT] < input.txt
#          ./delim_sed.sh '[[:space:]:]+' ', ' < people.txt
#          cat people.txt | ./delim_sed.sh '[[:space:]:]+'
#
# Input:   PATTERN is required: an extended regex such as '[[:space:]:]+'
#          (whitespace or colon). REPLACEMENT is optional and defaults to ", ".
#          Text lines come from standard input.
# Output:  Every input line, with all matches of PATTERN replaced, on
#          standard output. Usage errors go to standard error.
# Note:    In REPLACEMENT, & stands for the matched text and \1 for group 1.
# Exit:    0 on success, 2 if the script was used incorrectly.

# Require the PATTERN argument.
if [ $# -lt 1 ]; then
  echo "Usage: $0 PATTERN [REPLACEMENT] < input.txt" >&2
  exit 2
fi

pattern="$1"
replacement="${2:-, }"   # default replacement is a comma and a space

# Use an unprintable character as the s command delimiter so that a "/" in the
# pattern or replacement does not break the command.
sep=$'\001'

# -E enables extended regex; the g flag replaces all matches on each line.
sed -E "s${sep}${pattern}${sep}${replacement}${sep}g"
