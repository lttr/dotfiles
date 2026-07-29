#!/usr/bin/env bash

# Estimate tokens for Claude input.
#
# Fast offline estimate, calibrated for the Opus 4.7+ / Opus 5 / Sonnet 5
# tokenizer, which produces roughly 1.0-1.35x the tokens of the older Claude
# tokenizer for the same text. Expect +-15%.

set -uo pipefail

usage() {
    echo "Usage: aitokens <file1> [file2] [...]"
    echo "       find . -name '*.txt' | aitokens"
    exit 1
}

while [ $# -gt 0 ] && [[ "$1" == -* ]]; do
    case "$1" in
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# No files and stdin is a terminal -> interactive mode, nothing to do
if [ $# -eq 0 ] && [ -t 0 ]; then
    usage
fi

# Offline estimate. Chars-per-token differs by content density:
# prose ~3.0, code/markup ~2.7 on the current tokenizer.
count_estimate() {
    local chars=$1 words=$2
    if [ "$words" -gt 0 ] && [ $((chars / words)) -lt 8 ]; then
        echo $((chars * 10 / 30))
    else
        echo $((chars * 10 / 27))
    fi
}

fmt() { printf "%'d" "$1" | tr ',' ' '; }

total_chars=0
total_tokens=0
valid_files=0

if [ $# -gt 0 ]; then
    files=("$@")
else
    mapfile -t files
fi

for FILE in "${files[@]}"; do
    [ -d "$FILE" ] && continue

    if [ ! -f "$FILE" ]; then
        echo "Error: File not found: $FILE" >&2
        continue
    fi

    ((valid_files++))

    char_count=$(wc -c < "$FILE")
    word_count=$(wc -w < "$FILE")
    tokens=$(count_estimate "$char_count" "$word_count")

    # Per-file detail only makes sense for a single file
    if [ ${#files[@]} -eq 1 ]; then
        echo "File: $FILE ($(fmt "$char_count") chars, $(fmt "$word_count") words) $(fmt "$tokens") tokens (estimate)"
    fi

    total_chars=$((total_chars + char_count))
    total_tokens=$((total_tokens + tokens))
done

if [ "$valid_files" -eq 0 ]; then
    exit 1
fi

if [ ${#files[@]} -gt 1 ]; then
    echo "Total: $valid_files files ($(fmt "$total_chars") chars)"
    echo "Combined tokens: $(fmt "$total_tokens")"
fi
