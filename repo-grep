#!/usr/bin/env bash

# repo-grep: Search for text in a git repository
# Usage: repo-grep "search term"
if [ $# -eq 0 ]; then
    echo "Usage: repo-grep \"search term\""
    echo "Searches for the given term in all files in the git repository"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --show-toplevel > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)

# Perform the search with color
# Use ripgrep if available (better colors and performance), otherwise use grep
if command -v rg &> /dev/null; then
    rg -n "$1" "$REPO_ROOT"
else
    grep -rnw --color=always "$REPO_ROOT" -e "$1"
fi
