#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/ami_setup
cp -r /tmp/server_scripts /usr/local/ami_setup/
cp -r /tmp/shared /usr/local/ami_setup/

yum update
yum upgrade -y
yum autoremove
yum clean all
yum update


reboot
