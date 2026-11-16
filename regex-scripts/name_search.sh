#!/bin/bash
# Name: Ahmed Aldeek
# Script: name_search.sh (idea 1, grep version)
#
# Purpose: Print the input lines that contain a literal name pattern.
#
# Usage:   ./name_search.sh NAME [FILE]
#          ./name_search.sh Lizzy < people.txt
#          cat people.txt | ./name_search.sh Lizzy
#
# Input:   NAME is required and comes from the command line.
#          Lines come from FILE if given, otherwise from standard input.
# Output:  Matching lines on standard output (one per line, unchanged),
#          so the result can be piped into other commands.
#          Usage errors go to standard error.
# Exit:    0 if a line matched, 1 if none matched (grep convention),
#          2 if the script was used incorrectly.

# Require at least the NAME argument.
if [ $# -lt 1 ]; then
  echo "Usage: $0 NAME [FILE]" >&2
  exit 2
fi

name="$1"
shift

# -F treats NAME as a literal string, not a regex (so "Lizzy" or "J.R." match exactly).
# -e keeps a name that starts with "-" from being read as an option.
# "$@" is the optional FILE; with no file, grep reads standard input.
grep -F -e "$name" "$@"
