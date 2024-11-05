#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/ami_setup
cp -r /tmp/server_scripts /usr/local/ami_setup/
cp -r /tmp/shared /usr/local/ami_setup/

dnf update
source /usr/local/ami_setup/shared/al2023/system-upgrade.sh
dnf upgrade -y
dnf autoremove
dnf clean all
dnf update

reboot
