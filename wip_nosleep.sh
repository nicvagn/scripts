#!/usr/bin/env bash

while [ True ]
do
    systemd-inhibit --why="Disable sleep" --mode=block /usr/bin/bash -c "while true; do sleep 120; done"
done

echo "Can sleep again"
