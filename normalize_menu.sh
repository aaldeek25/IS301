#!/bin/bash
# Author: Ahmed Aldeek (IS301, Automate data normalization part 3)
# Purpose: turn scraped Chart House menu text into CSV, one row per dish.
# Usage:   ./normalize_menu.sh scrape.txt > menu.csv   (or: cat scrape.txt | ./normalize_menu.sh)
# Output:  CSV to standard output: Category,Dish,Ingredients,Price,Note
# Method:  prune with pipes (keep only the menu, trim, drop blanks and noise), then a
#          while-loop builds each record: first line is the dish, later lines are
#          ingredients, a price line closes the record. "|" becomes ";", tier prices
#          (cup $11) and "per MP" go to Note. Edit NOISE and SECTIONS to tune.

NOISE='^(starters|menu|home|reserve|reservations|order online|locations|gift cards|careers|contact|view full menu|skip to content|chef[^|]*farm fresh harvest.*)$'

# Regex for an optional "(inquire ...)" remark inside the ingredient text
REMARK='\(?(inquire[^|)]*)\)?'

# Section headings (set the Category column) and tier-price lines like "cup $11"
SECTIONS='^(appetizers|soups \+ salads|catch|chef[^ ]+s feature|highly recommended|entrees - .*|sides)$'
TIER='^.+[[:space:]]\$[0-9]+(\.[0-9]{2})?$'

# Wrap a value in quotes and double any embedded quotes (CSV rule)
csv() { local v="${1//\"/\"\"}"; printf '"%s"' "$v"; }

echo "Category,Dish,Ingredients,Price,Note"

shopt -s nocasematch

# Write one finished record to standard output
emit() {
  local ing="$ingredients" price="$1" note="$2" remark
  # Pull an "(inquire ...)" or "inquire ..." remark out of the ingredients
  if [[ "$ing" =~ $REMARK ]]; then
    remark="${BASH_REMATCH[1]}"
    ing="${ing/${BASH_REMATCH[0]}/}"
    note="${note:+$note; }$remark"
  fi
  # Normalize separators: "a | b|c" -> "a; b; c"
  ing=$(sed -E 's/[[:space:]]*\|[[:space:]]*/; /g; s/[[:space:]]+/ /g; s/^[; ]+//; s/[; ]+$//' <<< "$ing")
  echo "$(csv "$category"),$(csv "$name"),$(csv "$ing"),$price,$(csv "$note")"
  name=""; ingredients=""; variants=""
}

category=""; name=""; ingredients=""; variants=""

cat "${1:--}" |
tr -d '\r' |                                        # Remove Windows line endings
sed -n '/^[[:space:]]*Appetizers[[:space:]]*$/,/^Facebook/p' |   # Keep only the menu span
grep -v '^Facebook' |
sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' |     # Trim leading/trailing whitespace
grep -v '^$' |                                      # Remove empty lines
grep -Eiv "$NOISE" |                                # Remove navigation/heading lines
while IFS= read -r line; do

  # A pending record with tier prices is closed by the first non-tier line
  if [ -n "$variants" ] && ! [[ "$line" =~ $TIER ]]; then
    emit "" "$variants"
  fi

  if [[ "$line" =~ $SECTIONS ]]; then
    category="$line"; name=""; ingredients=""; variants=""        # New section

  elif [[ "$line" =~ ^\$?[0-9]+(\.[0-9]{2})?$ ]] || [[ "$line" =~ ^(per[[:space:]]+)?MP$ ]]; then
    [ -z "$name" ] && continue                                    # Price with no dish
    if [[ "$line" =~ ^(per[[:space:]]+)?MP$ ]]; then
      emit "" "market price"
    else
      emit "${line#\$}" ""
    fi

  elif [ -n "$name" ] && [[ "$line" =~ $TIER ]]; then
    variants="${variants:+$variants; }$line"                      # cup $11, bowl $14...

  elif [ -z "$name" ]; then
    name="$line"                                                  # First line of a record
  else
    ingredients="${ingredients:+$ingredients }$line"              # Append (wrapped) ingredient text
  fi

done
if [ -n "$variants" ]; then emit "" "$variants"; fi               # Flush last record
