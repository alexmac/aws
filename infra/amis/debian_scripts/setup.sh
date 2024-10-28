#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

mkdir -p /usr/local/ami_setup
cp -r /tmp/debian_scripts /usr/local/ami_setup
cp -r /tmp/shared /usr/local/ami_setup

apt-get update
apt-get upgrade -y
apt-get update

apt-get install -y \
	python3-pip chrony

pip3 install -U --break-system-packages --ignore-installed \
	awscli requests
pip3 check

source /usr/local/ami_setup/shared/debian/ssh-harden.sh
source /usr/local/ami_setup/shared/ubuntu/chrony.sh

cp /usr/local/ami_setup/shared/ubuntu/sign-ssh-host-key.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/sign-ssh-host-key.timer /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/01-cloud-init-custom.cfg /etc/cloud/cloud.cfg.d/

systemctl enable ssh
systemctl enable sign-ssh-host-key.service
systemctl enable sign-ssh-host-key.timer

source /usr/local/ami_setup/shared/debian/clean.sh
