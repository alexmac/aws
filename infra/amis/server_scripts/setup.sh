#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/ami_setup
cp -r /tmp/server_scripts /usr/local/ami_setup/

yum update
yum upgrade -y
yum update

yum install -y \
	docker jq ec2-instance-connect python3-pip \
	htop git ecs-init vim aws-nitro-enclaves-cli \
	aws-nitro-enclaves-cli-devel wget

pip3 install -U \
	awscli

aws configure set default.region us-west-2

source /usr/local/ami_setup/server_scripts/ssh-harden.sh

source /usr/local/ami_setup/server_scripts/nitro-enclave.sh

cp /usr/local/ami_setup/server_scripts/docker-daemon.json /etc/docker/daemon.json
usermod -aG docker ec2-user

cp /usr/local/ami_setup/server_scripts/startup.service /etc/systemd/system/
cp /usr/local/ami_setup/server_scripts/sign-ssh-host-key.service /etc/systemd/system/
cp /usr/local/ami_setup/server_scripts/sign-ssh-host-key.timer /etc/systemd/system/

systemctl enable startup
systemctl enable sign-ssh-host-key.service
systemctl enable sign-ssh-host-key.timer
systemctl enable docker
systemctl enable ecs
