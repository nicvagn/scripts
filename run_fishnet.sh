#!/bin/bash

if systemctl --user is-active fishnet; then
	echo "Exiting fishnet"
	systemctl --user stop fishnet
	echo "systemctl --user stop fishnet ran"
else

	systemctl --user start fishnet
	echo "[[[[ fishnet started ]]]]"
fi
