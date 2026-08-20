#!/usr/bin/env bash
FILE="$1"
if [ -z "$FILE" ]; then
    echo "Usage: $0 <path_to_skill.md>"
    exit 1
fi
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi
DESC=$(sed -n 's/.*<skill-details.*description="\([^"]*\)".*/\1/p' "$FILE" | head -n 1)
if [ -z "$DESC" ]; then
    echo "Error: <skill-details> tag or 'description' attribute missing in '$FILE'."
    exit 1
fi
LEN=$(printf "%s" "$DESC" | wc -c | tr -d ' ')
if [ "$LEN" -gt 140 ]; then
    echo "Error: Description exceeds 140 characters."
    exit 1
fi
echo "Success: Description is valid ($LEN chars)."
exit 0