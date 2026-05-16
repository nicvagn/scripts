#!/bin/bash
if [[ "$(systemctl --user is-enabled sleep.target 2>/dev/null)" -eq "masked" ]]
then
    systemctl --user unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
    echo "sleep unmasked"
else
    echo "sleep not masked"
fi
