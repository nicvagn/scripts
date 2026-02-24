#!/bin/bash

# Git Repository Search Script
# Usage: ./git_find.sh "search_text" [file_pattern]

set -e  # Exit on any error

# Validate arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing required argument: search_text${NC}"
    show_usage
    exit 1
fi
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_usage() {
    echo "Usage: $1 \"search_text\" [file_pattern]"
    echo ""
    echo "Examples:"
    echo "  $1 \"oldFunction\""
    echo "  $1 \"TODO\" \"*.js\""
    echo "  $1 \"api.example.com\" \"*.config\""
    echo ""
    echo "Options:"
    echo "  -h, --help     - Show this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage; exit 0 ;;
        *)
            break ;;
    esac
done

# enter Git repository root
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
echo "git root: $ROOT"

SEARCH_TEXT="$1"
FILE_PATTERN="${2:-*}"

# Escape string for grep safety
ESCAPED_SEARCH=$(printf '%s\n' "$SEARCH_TEXT" | sed 's/[][\/.^$*]/\\&/g')

echo -e "${BLUE}Git Repository Search${NC}"
echo -e "Search for: ${YELLOW}$SEARCH_TEXT${NC}"
echo -e "File pattern: ${YELLOW}$FILE_PATTERN${NC}\n"

# Find matching files
echo -e "${BLUE}Searching...${NC}"

MATCHING_FILES=$(
  grep -rIl \
    --exclude-dir=.git \
    --include="${FILE_PATTERN}" \
    -- "$ESCAPED_SEARCH" "$ROOT" 2>/dev/null
)

if [ -z "$MATCHING_FILES" ]; then
    echo -e "${YELLOW}No matches found${NC}"
    exit 0
fi

echo -e "${GREEN}Files with matches:${NC}"
while read -r file; do
    [ -z "$file" ] && continue
    count=$(grep -c "$ESCAPED_SEARCH" "$file" 2>/dev/null || echo "0")
    echo -e "  ${GREEN}$file${NC} (${count} matches)"
done <<< "$MATCHING_FILES"

echo ""
echo -e "${BLUE}Match details (first 5 per file):${NC}"

while read -r file; do
    [ -z "$file" ] && continue
    echo -e "${YELLOW}--- $file ---${NC}"
    grep -n "$ESCAPED_SEARCH" "$file" | head -5 | while read -r line; do
        echo -e "  ${RED}$line${NC}"
    done
    total=$(grep -c "$ESCAPED_SEARCH" "$file" 2>/dev/null || echo "0")
    if [ "$total" -gt 5 ]; then
        echo -e "  ${BLUE}... and $((total - 5)) more matches${NC}"
    fi
    echo ""
done <<< "$MATCHING_FILES"

echo -e "${GREEN}Search complete.${NC}"
