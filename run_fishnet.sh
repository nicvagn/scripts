#!/bin/bash
echo "ran: systemctl --user start fishnet"
systemctl --user start fishnet
bash /home/nrv/scripts/nosleep.sh
systemctl --user stop fishnet
echo "systemctl --user stop fishnet"
