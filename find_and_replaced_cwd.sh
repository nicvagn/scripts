#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 OLD_TEXT NEW_TEXT"
    exit 1
fi

DIR=$(pwd)
OLD="$1"
NEW="$2"

while true; do
  echo "going to execute: grep -rl --exclude-dir=.git '$OLD' $DIR | xargs sed -i 's/$OLD/$NEW/g'"
  read -p "Press Y to continue, or any other key to exit must be capital y" input
  if [[ "$input" = "Y" ]]; then
    echo "Replacing: $OLD  with $NEW in:" && pwd
  else
    echo "CANCELLED"
    exit 0
  fi
done

# Recursive find-and-replace in current directory
grep -rl --exclude-dir=.git "$OLD" $DIR | xargs sed -i "s/$OLD/$NEW/g"

echo "Replaced '$OLD' with '$NEW' in all matching files in $DIR"

#  LocalWords:  sed
