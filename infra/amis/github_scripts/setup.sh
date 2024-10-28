#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

mkdir -p /usr/local/ami_setup
cp -r /tmp/github_scripts /usr/local/ami_setup
cp -r /tmp/shared /usr/local/ami_setup

apt-get update
apt-get upgrade -y
apt-get update

apt-get install -y \
	python3-pip

pip3 install -U --break-system-packages --ignore-installed \
	awscli requests

source /usr/local/ami_setup/shared/ubuntu/ssh-harden.sh
source /usr/local/ami_setup/shared/ubuntu/chrony.sh

# Install Github Actions Runner
export GH_ACTIONS_VERSION=2.320.0
mkdir -p /actions-runner
pushd /actions-runner
curl -O -L "https://github.com/actions/runner/releases/download/v${GH_ACTIONS_VERSION}/actions-runner-linux-arm64-${GH_ACTIONS_VERSION}.tar.gz"
tar xzf "./actions-runner-linux-arm64-${GH_ACTIONS_VERSION}.tar.gz"
rm "./actions-runner-linux-arm64-${GH_ACTIONS_VERSION}.tar.gz"
./bin/installdependencies.sh
chown -R ubuntu:ubuntu .
popd

cp /usr/local/ami_setup/github_scripts/startup.service /etc/systemd/system/
cp /usr/local/ami_setup/github_scripts/shutdown.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/sign-ssh-host-key.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/sign-ssh-host-key.timer /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/01-cloud-init-custom.cfg /etc/cloud/cloud.cfg.d/

systemctl disable ModemManager
systemctl enable startup
systemctl enable shutdown
systemctl enable sign-ssh-host-key.service
systemctl enable sign-ssh-host-key.timer

source /usr/local/ami_setup/shared/ubuntu/clean.sh
