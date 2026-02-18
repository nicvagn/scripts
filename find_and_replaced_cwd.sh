#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 OLD_TEXT NEW_TEXT"
    exit 1
fi

DIR=$(pwd)
OLD="$1"
NEW="$2"

echo "Going to execute:"
echo "grep -rlZ --exclude-dir=.git '$OLD' $DIR | xargs -0 -r sed -i 's|$OLD|$NEW|g'"

read -p "Press Y to continue, or any other key to exit (must be capital Y): " input

if [[ "$input" = "Y" ]]; then
    echo "Replacing: $OLD with $NEW in $DIR"
    grep -rlZ --exclude-dir=.git "$OLD" "$DIR" \
        | xargs -0 -r sed -i "s|$OLD|$NEW|g"
else
    echo "CANCELLED"
    exit 0
fi
#  LocalWords:  sed
