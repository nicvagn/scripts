#!/bin/bash
password=$(<"/home/nrv/.keyring_pass")
/usr/bin/gnome-keyring-daemon --unlock <<< "$password"
