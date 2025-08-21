#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 OLD_TEXT NEW_TEXT"
fi

DIR=$(pwd)
OLD="$1"
NEW="$2"

echo "executed: sed -i s/$OLD/$NEW/g"
# Recursive find-and-replace in current directory
grep -rl --exclude-dir=.git "$OLD" $DIR | xargs sed -i "s/$OLD/$NEW/g"

echo "Replaced '$OLD' with '$NEW' in all matching files in $DIR"

#  LocalWords:  sed
