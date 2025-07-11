#!/usr/bin/env bash

echo "sleep disabled"
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

read -p "allow sleep with input" -n 1 -r

sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Can sleep again"
