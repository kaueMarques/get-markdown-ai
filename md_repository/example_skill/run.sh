#!/usr/bin/env bash

echo "Starting Data Processor Skill..."

if [ -f "data.json" ]; then
    echo "Loading parameters from data.json:"
    cat data.json
    echo ""
else
    echo "Warning: data.json not found!"
fi

echo "Processing complete."
