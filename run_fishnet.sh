#!/bin/bash
echo "[[[[ fishnet started ]]]]"
systemctl --user start fishnet
read -p "Exit fishnet and allow sleep with input"
systemctl --user stop fishnet
echo "systemctl --user stop fishnet ran"
