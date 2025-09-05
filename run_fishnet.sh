#!/bin/bash
echo "[[[[ fishnet started ]]]]"
systemctl --user start fishnet
/home/nrv/scripts/nosleep.sh
systemctl --user stop fishnet
echo "systemctl --user stop fishnet ran"
