#!/bin/bash
systemctl --user start fishnet
bash /home/nrv/scripts/nosleep.sh
systemctl --user stop fishnet
