#!/usr/bin/env bash

# Find text in current wd
set -e # Exit on any error

show_usage() {
	echo "Usage: $0 \"search_text\""
}

# Check if no arguments provided
if [ $# -eq 0 ]; then
	echo "Error: Search text required"
	show_usage
	exit 1
fi

if [[ $# > 1 ]]; then
	echo "only on argument for search text is allowed. Use \"arg\" to include \" \""
	exit 1
fi

while [[ $# > 0 ]]; do
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

grep -rni --colour=auto "$1" .
