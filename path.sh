#!/usr/bin/env bash

if [[ $# !=  1 ]]; then
    pwd
else
    readlink -f $1
fi
