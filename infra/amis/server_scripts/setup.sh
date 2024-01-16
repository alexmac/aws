#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/ami_setup
cp -r /tmp/server_scripts /usr/local/ami_setup/

yum update
yum upgrade -y
yum update

yum install -y \
	docker jq ec2-instance-connect python3-pip \
	htop git ecs-init vim

pip3 install -U \
	awscli

aws configure set default.region us-west-2
# aws configure set default.credential_source Ec2InstanceMetadata

source /usr/local/ami_setup/server_scripts/ssh-harden.sh

cp /usr/local/ami_setup/server_scripts/startup.service /etc/systemd/system/

usermod -a -G docker ec2-user

systemctl enable startup
systemctl enable docker
systemctl enable ecs
