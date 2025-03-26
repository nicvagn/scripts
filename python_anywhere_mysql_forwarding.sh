#!/usr/bin/env bash
echo "port 3306 tunnel - You must keep this ssh con running"

ssh -L 3306:nrv773.mysql.pythonanywhere-services.com:3306 nrv773@ssh.pythonanywhere.com
