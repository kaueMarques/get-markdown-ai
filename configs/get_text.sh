#!/usr/bin/env bash

NODE="$1"
if [ -z "$NODE" ]; then
    exit 1
fi

TOML_FILE="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)/texts.toml"

if [ ! -f "$TOML_FILE" ]; then
    exit 1
fi

awk -v node="$NODE" '
    $0 ~ "^"node" *= *\"\"\"" {flag=1; next}
    $0 ~ "^\"\"\"" {if(flag) exit}
    flag {print}
' "$TOML_FILE"