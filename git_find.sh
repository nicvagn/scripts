#!/bin/bash

# Git Repository Search Script
# Usage: ./git_find.sh "search_text" [file_pattern]

set -e # Exit on any error

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
	-h | --help)
		show_usage
		exit 0
		;;
	*)
		break
		;;
	esac
done

# enter Git repository root
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || $(echo "not in git repo." && exit 1)
echo "git root: $ROOT"

SEARCH_TEXT="$1"
FILE_PATTERN="${2:-*}"

echo -e "${BLUE}Git Repository Search${NC}"
echo -e "Search for: ${YELLOW}$SEARCH_TEXT${NC}"
echo -e "File pattern: ${YELLOW}$FILE_PATTERN${NC}\n"

echo -e "${BLUE}Searching...${NC}"

MATCHING_FILES=$(
  grep -rIlF \
    --exclude-dir=.git \
    --include="${FILE_PATTERN:-*}" \
    -- "$SEARCH_TEXT" "$ROOT" 2>/dev/null || true
)

if [[ -z "$MATCHING_FILES" ]]; then
    echo -e "${YELLOW}No matches found${NC}"
    exit 0
fi

echo -e "${GREEN}Files with matches:${NC}"

while IFS= read -r file; do
    matches=$(grep -nF "$SEARCH_TEXT" "$file" 2>/dev/null || true)
    count=$(printf '%s\n' "$matches" | wc -l)

    echo -e "  ${GREEN}$file${NC} (${count} matches)"
done <<< "$MATCHING_FILES"

echo ""
echo -e "${BLUE}Match details (first 5 per file):${NC}"

while IFS= read -r file; do
    matches=$(grep -nF "$SEARCH_TEXT" "$file" 2>/dev/null || true)
    count=$(printf '%s\n' "$matches" | wc -l)

    echo -e "${YELLOW}--- $file ---${NC}"

    printf '%s\n' "$matches" | head -5 | while IFS= read -r line; do
        echo -e "  ${RED}$line${NC}"
    done

    if (( count > 5 )); then
        echo -e "  ${BLUE}... and $((count - 5)) more matches${NC}"
    fi

    echo ""
done <<< "$MATCHING_FILES"

echo -e "${GREEN}Search complete.${NC}"
