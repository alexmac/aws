#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/ami_setup
cp -r /tmp/server_scripts /usr/local/ami_setup/
cp -r /tmp/shared /usr/local/ami_setup/

yum update
yum upgrade -y
yum update

yum install -y \
	docker jq ec2-instance-connect python3-pip \
	htop git ecs-init vim aws-nitro-enclaves-cli \
	aws-nitro-enclaves-cli-devel wget dnsutils \
	amazon-ssm-agent

curl https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-arm64-3.x.rpm -o /tmp/xray.rpm
yum install -y /tmp/xray.rpm
rm /tmp/xray.rpm

curl https://aws-otel-collector.s3.amazonaws.com/amazon_linux/arm64/latest/aws-otel-collector.rpm -o /tmp/aws-otel-collector.rpm
yum install -y /tmp/aws-otel-collector.rpm
rm /tmp/aws-otel-collector.rpm
/opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a start
/opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a stop

pip3 install -U \
	awscli

aws configure set default.region us-west-2

source /usr/local/ami_setup/shared/al2023/ssh-harden.sh

source /usr/local/ami_setup/shared/al2023/nitro-enclave.sh

cp /usr/local/ami_setup/server_scripts/docker-daemon.json /etc/docker/daemon.json
usermod -aG docker ec2-user

cp /usr/local/ami_setup/server_scripts/startup.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/al2023/sign-ssh-host-key.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/al2023/sign-ssh-host-key.timer /etc/systemd/system/

systemctl start docker
source /usr/local/ami_setup/server_scripts/pull-latest-images.sh
systemctl stop docker

systemctl enable aws-otel-collector
systemctl enable startup
systemctl enable sign-ssh-host-key.service
systemctl enable sign-ssh-host-key.timer
systemctl enable amazon-ssm-agent
systemctl enable docker
systemctl enable ecs

source /usr/local/ami_setup/shared/al2023/clean.sh
