#!/usr/bin/env bash

TARGET_DIRS="$*"
[ -z "$TARGET_DIRS" ] && [ -f "config.toml" ] && TARGET_DIRS=$(grep "^target_dirs" config.toml 2>/dev/null | sed 's/.*\[\(.*\)\].*/\1/' | tr -d '"' | tr ',' ' ')
TARGET_DIRS="${TARGET_DIRS:-.}"

for d in $TARGET_DIRS; do
    [ ! -d "$d" ] && echo "Error: Directory '$d' does not exist." && exit 1
done

TEMP_FILE=$(mktemp)

find $TARGET_DIRS -type d \( -name "node_modules" -o -name ".git" \) -prune -o -type f -iname "*.md" -print | sort | while read -r file; do
    NAME=$(sed -n 's/.*name="\([^"]*\)".*/\1/p' "$file" | head -n 1)
    DESC=$(sed -n 's/.*description="\([^"]*\)".*/\1/p' "$file" | head -n 1)
    TAGS=$(sed -n 's/.*tags="\([^"]*\)".*/\1/p' "$file" | head -n 1)
    [ -z "$NAME" ] && NAME=$(basename "$(dirname "$file")")
    echo "$file,$NAME,$DESC,$TAGS" >> "$TEMP_FILE"
done

COUNT=$(wc -l < "$TEMP_FILE" | tr -d ' ')

> skills.toon
echo "skills[$COUNT]{path,name,description,tags}:" >> skills.toon
cat "$TEMP_FILE" >> skills.toon
rm -f "$TEMP_FILE"

cat skills.toon