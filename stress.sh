#!/usr/bin/env bash
for i in $(seq $(getconf _NPROCESSORS_ONLN)); do yes > /dev/null & done
echo "started a bunch of yes, killall yes to kill"
