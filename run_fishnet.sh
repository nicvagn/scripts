#!/bin/bash
echo "[[[[ fishnet started ]]]]"
systemctl --user start fishnet
echo "Exit fishnet and allow sleep with input"
/home/nrv/scripts/nosleep.sh > /dev/null
systemctl --user stop fishnet
echo "systemctl --user stop fishnet ran"
