#!/usr/bin/env bash

# Estimate tokens for Claude Sonnet input

# Check if no arguments and stdin is terminal (interactive mode)
if [ $# -eq 0 ] && [ -t 0 ]; then
    echo "Usage: aitokens <file1> [file2] [...]"
    echo "       find . -name '*.txt' | aitokens"
    exit 1
fi

# Initialize counters
total_chars=0
total_words=0
total_tokens=0
file_count=0
valid_files=0

# Read files from arguments or stdin
if [ $# -gt 0 ]; then
    files=("$@")  # Use command line arguments
else
    mapfile -t files  # Read from stdin line by line
fi

for FILE in "${files[@]}"; do
    ((file_count++))
    
    # Skip directories silently
    if [ -d "$FILE" ]; then
        continue
    fi
    
    # Skip non-existent files with error message
    if [ ! -f "$FILE" ]; then
        echo "Error: File not found: $FILE"
        continue
    fi
    
    ((valid_files++))
    
    # Count characters and words using wc
    char_count=$(wc -c < "$FILE")
    word_count=$(wc -w < "$FILE")
    
    # Calculate token estimates using different methods
    tokens_chars=$((char_count / 4))  # General rule: 4 chars per token
    tokens_words=$((word_count * 130 / 100))  # 1.3 tokens per word
    
    # Choose estimation method based on content type
    # Word-based for text (low char/word ratio), code-based for dense content
    if [ $word_count -gt 0 ] && [ $((char_count / word_count)) -lt 10 ]; then
        estimate=$tokens_words
        method="word-based"
    else
        estimate=$((char_count * 10 / 35))  # Code: ~3.5 chars per token
        method="code-based"
    fi
    
    # Show per-file details only for single file input
    if [ ${#files[@]} -eq 1 ]; then
        # Format numbers with Czech thousands separators (spaces)
        formatted_chars=$(printf "%'d" $char_count | tr ',' ' ')
        formatted_words=$(printf "%'d" $word_count | tr ',' ' ')
        formatted_estimate=$(printf "%'d" $estimate | tr ',' ' ')
        echo "File: $FILE ($formatted_chars chars, $formatted_words words) $formatted_estimate tokens ($method)"
    fi
    
    # Accumulate totals
    total_chars=$((total_chars + char_count))
    total_words=$((total_words + word_count))
    total_tokens=$((total_tokens + estimate))
done

# Exit if no valid files were processed
if [ $valid_files -eq 0 ]; then
    exit 1
fi

# Show summary for multiple files, context warnings for all cases
if [ ${#files[@]} -gt 1 ]; then
    # Format totals with Czech number formatting
    formatted_total_chars=$(printf "%'d" $total_chars | tr ',' ' ')
    formatted_total_words=$(printf "%'d" $total_words | tr ',' ' ')
    formatted_total_tokens=$(printf "%'d" $total_tokens | tr ',' ' ')
    echo "Total: $valid_files files ($formatted_total_chars chars, $formatted_total_words words)"
    echo "Combined estimated tokens: $formatted_total_tokens"
fi
