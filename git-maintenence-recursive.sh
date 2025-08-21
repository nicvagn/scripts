#!/usr/bin/env bash
# git-maintenance-recursive.sh
# Run git maintenance on all Git repos under the current directory

# Find all Git repositories recursively
find . -type d -name ".git" | while read -r gitdir; do
    repo=$(dirname "$gitdir")
    echo "=== Running maintenance in $repo ==="
    git -C "$repo" maintenance run
done
