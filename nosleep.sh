#!/usr/bin/env bash

systemctl --user mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "sleep masked"
