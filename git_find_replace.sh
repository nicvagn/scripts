#!/bin/bash

# Git Repository Find and Replace Script
# Usage: ./git_find_replace.sh "search_text" "replace_text" [file_pattern]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_usage() {
    echo "Usage: $0 \"search_text\" \"replace_text\" [file_pattern]"
    echo ""
    echo "Examples:"
    echo "  $0 \"oldFunction\" \"newFunction\""
    echo "  $0 \"TODO\" \"DONE\" \"*.js\""
    echo "  $0 \"api.example.com\" \"api.newdomain.com\" \"*.config\""
    echo ""
    echo "Options:"
    echo "  -h, --help     - Show this help message"
    echo "  -p, --preview  - Preview changes without applying them"
}

# Parse arguments
PREVIEW_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage; exit 0 ;;
        -p|--preview)
            PREVIEW_MODE=true; shift ;;
        *)
            break ;;
    esac
done

# Ensure we are inside a Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Validate arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    show_usage
    exit 1
fi

SEARCH_TEXT="$1"
REPLACE_TEXT="$2"
FILE_PATTERN="${3:-*}"

# Escape strings for safety in grep and sed
ESCAPED_SEARCH=$(printf '%s\n' "$SEARCH_TEXT" | sed 's/[][\/.^$*]/\\&/g')
ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE_TEXT" | sed 's/[&/]/\\&/g')

echo -e "${BLUE}Git Repository Find and Replace${NC}"
echo -e "Search for: ${YELLOW}$SEARCH_TEXT${NC}"
echo -e "Replace with: ${YELLOW}$REPLACE_TEXT${NC}"
echo -e "File pattern: ${YELLOW}$FILE_PATTERN${NC}"
echo -e "Preview mode: ${YELLOW}$PREVIEW_MODE${NC}\n"

# Find matching files
echo -e "${BLUE}Searching for files containing '$SEARCH_TEXT'...${NC}"
MATCHING_FILES=$(git ls-files | grep -E "$(echo "$FILE_PATTERN" | sed 's/\*/.*/g')" \
    | xargs grep -l "$ESCAPED_SEARCH" 2>/dev/null || true)

if [ -z "$MATCHING_FILES" ]; then
    echo -e "${YELLOW}No files found containing '$SEARCH_TEXT'${NC}"
    exit 0
fi

echo -e "${GREEN}Found matching files:${NC}"
while read -r file; do
    [ -z "$file" ] && continue
    count=$(grep -c "$ESCAPED_SEARCH" "$file" 2>/dev/null || echo "0")
    echo -e "  ${GREEN}$file${NC} (${count} matches)"
done <<< "$MATCHING_FILES"
echo ""

# Preview mode
if $PREVIEW_MODE; then
    echo -e "${BLUE}Preview of changes:${NC}"
    while read -r file; do
        [ -z "$file" ] && continue
        echo -e "${YELLOW}--- $file ---${NC}"
        grep -n "$ESCAPED_SEARCH" "$file" | head -5 | while read -r line; do
            echo -e "${RED}- $line${NC}"
            echo -e "${GREEN}+ $(echo "$line" | sed "s/$ESCAPED_SEARCH/$ESCAPED_REPLACE/g")${NC}"
        done
        total=$(grep -c "$ESCAPED_SEARCH" "$file" 2>/dev/null || echo "0")
        if [ "$total" -gt 5 ]; then
            echo -e "${BLUE}... and $((total - 5)) more matches${NC}"
        fi
        echo ""
    done <<< "$MATCHING_FILES"
    exit 0
fi

# Confirm action
echo -e "${YELLOW}This will modify the above files. Continue? (y/N):${NC} "
read -r confirmation
if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled${NC}"
    exit 0
fi

# Perform replacements
echo -e "${BLUE}Performing replacements...${NC}"
TOTAL_REPLACEMENTS=0
while read -r file; do
    [ -z "$file" ] && continue

    # Count matches before replacement, normalize to 0
    before_count=$(grep -c "$ESCAPED_SEARCH" "$file" 2>/dev/null || true)
    before_count=$((before_count + 0))

    if [ "$before_count" -gt 0 ]; then
        cp "$file" "$file.bak"

        if sed -i "s|$ESCAPED_SEARCH|$ESCAPED_REPLACE|g" "$file"; then
            after_count=$(grep -c "$ESCAPED_SEARCH" "$file" 2>/dev/null || true)
            after_count=$((after_count + 0))

            actual_replacements=$((before_count - after_count))
            TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + actual_replacements))

            echo -e "  ${GREEN}✓ $file${NC} - ${actual_replacements} replacements"
            rm "$file.bak"
        else
            echo -e "  ${RED}✗ Failed to process $file${NC}"
            mv "$file.bak" "$file"
        fi
    fi
done <<< "$MATCHING_FILES"

echo -e "\n${GREEN}Replacement complete!${NC}"
echo -e "Total replacements made: ${GREEN}$TOTAL_REPLACEMENTS${NC}\n"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review changes: git diff"
echo "2. Test your changes"
echo "3. Stage changes: git add ."
echo "4. Commit: git commit -m \"Replace '$SEARCH_TEXT' with '$REPLACE_TEXT'\""
