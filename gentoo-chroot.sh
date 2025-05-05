#!/bin/env bash

echo "copying resolv.conf networking config?"
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

echo "mounting /proc /sys /dev /run"
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

echo "chrooting into /mnt/gentoo"
chroot /mnt/gentoo
