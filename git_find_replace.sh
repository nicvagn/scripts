#!/bin/bash

# Git Repository Find and Replace Script
# Usage: ./find_replace.sh "search_text" "replace_text" [file_pattern]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
show_usage() {
    echo "Usage: $0 \"search_text\" \"replace_text\" [file_pattern]"
    echo ""
    echo "Arguments:"
    echo "  search_text    - Text to search for (required)"
    echo "  replace_text   - Text to replace with (required)"
    echo "  file_pattern   - File pattern to search in (optional, default: all files)"
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

# Parse command line arguments
PREVIEW_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -p|--preview)
            PREVIEW_MODE=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    show_usage
    exit 1
fi

SEARCH_TEXT="$1"
REPLACE_TEXT="$2"
FILE_PATTERN="${3:-*}"

# Validate inputs
if [ -z "$SEARCH_TEXT" ]; then
    echo -e "${RED}Error: Search text cannot be empty${NC}"
    exit 1
fi

echo -e "${BLUE}Git Repository Find and Replace${NC}"
echo -e "${BLUE}===============================${NC}"
echo -e "Search for: ${YELLOW}$SEARCH_TEXT${NC}"
echo -e "Replace with: ${YELLOW}$REPLACE_TEXT${NC}"
echo -e "File pattern: ${YELLOW}$FILE_PATTERN${NC}"
echo -e "Preview mode: ${YELLOW}$PREVIEW_MODE${NC}"
echo ""

# Find files that contain the search text
echo -e "${BLUE}Searching for files containing '$SEARCH_TEXT'...${NC}"

# Use git ls-files to only search tracked files, then filter by pattern and grep for content
MATCHING_FILES=$(git ls-files | grep -E "$(echo "$FILE_PATTERN" | sed 's/\*/\.\*/g')" | xargs grep -l "$SEARCH_TEXT" 2>/dev/null || true)

if [ -z "$MATCHING_FILES" ]; then
    echo -e "${YELLOW}No files found containing '$SEARCH_TEXT'${NC}"
    exit 0
fi

echo -e "${GREEN}Found matching files:${NC}"
echo "$MATCHING_FILES" | while read -r file; do
    if [ -n "$file" ]; then
        # Count occurrences in this file
        count=$(grep -c "$SEARCH_TEXT" "$file" 2>/dev/null || echo "0")
        echo -e "  ${GREEN}$file${NC} (${count} matches)"
    fi
done
echo ""

# Show preview of changes if requested
if [ "$PREVIEW_MODE" = true ]; then
    echo -e "${BLUE}Preview of changes:${NC}"
    echo "$MATCHING_FILES" | while read -r file; do
        if [ -n "$file" ]; then
            echo -e "${YELLOW}--- $file ---${NC}"
            grep -n "$SEARCH_TEXT" "$file" | head -5 | while read -r line; do
                echo -e "${RED}- $line${NC}"
                echo -e "${GREEN}+ $(echo "$line" | sed "s/$SEARCH_TEXT/$REPLACE_TEXT/g")${NC}"
            done
            # Show "..." if there are more than 5 matches
            total_matches=$(grep -c "$SEARCH_TEXT" "$file")
            if [ "$total_matches" -gt 5 ]; then
                echo -e "${BLUE}... and $((total_matches - 5)) more matches${NC}"
            fi
            echo ""
        fi
    done
    exit 0
fi

# Ask for confirmation
echo -e "${YELLOW}This will modify the above files. Continue? (y/N):${NC} "
read -r confirmation
if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled${NC}"
    exit 0
fi

# Perform the replacement
echo -e "${BLUE}Performing replacements...${NC}"
TOTAL_REPLACEMENTS=0

echo "$MATCHING_FILES" | while read -r file; do
    if [ -n "$file" ]; then
        # Count matches before replacement
        before_count=$(grep -c "$SEARCH_TEXT" "$file" 2>/dev/null || echo "0")

        if [ "$before_count" -gt 0 ]; then
            # Create backup
            cp "$file" "$file.bak"

            # Perform replacement using sed
            if sed -i "s|$SEARCH_TEXT|$REPLACE_TEXT|g" "$file"; then
                # Count matches after replacement to verify
                after_count=$(grep -c "$SEARCH_TEXT" "$file" 2>/dev/null || echo "0")
                actual_replacements=$((before_count - after_count))

                echo -e "  ${GREEN}✓ $file${NC} - ${actual_replacements} replacements"
                TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + actual_replacements))

                # Remove backup if successful
                rm "$file.bak"
            else
                echo -e "  ${RED}✗ Failed to process $file${NC}"
                # Restore from backup
                mv "$file.bak" "$file"
            fi
        fi
    fi
done

echo ""
echo -e "${GREEN}Replacement complete!${NC}"
echo -e "Total replacements made: ${GREEN}$TOTAL_REPLACEMENTS${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review changes: git diff"
echo "2. Test your changes"
echo "3. Stage changes: git add ."
echo "4. Commit: git commit -m \"Replace '$SEARCH_TEXT' with '$REPLACE_TEXT'\""
#  LocalWords:  newFunction oldFunction
