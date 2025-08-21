#!/bin/bash
echo "fishnet started quit with any input"
systemctl --user start fishnet
bash /home/nrv/scripts/nosleep.sh
systemctl --user stop fishnet
echo "systemctl --user stop fishnet ran"
