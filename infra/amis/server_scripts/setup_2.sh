#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

source /usr/local/ami_setup/shared/universal/arch.sh

source /usr/local/ami_setup/shared/al2023/system-upgrade.sh
dnf install -y \
	docker jq ec2-instance-connect python3-pip \
	htop git ecs-init vim aws-nitro-enclaves-cli \
	aws-nitro-enclaves-cli-devel wget dnsutils \
	amazon-ssm-agent amazon-ecr-credential-helper

curl "${XRAY_RPM}" -o /tmp/xray.rpm
dnf install -y /tmp/xray.rpm
rm /tmp/xray.rpm

curl "https://aws-otel-collector.s3.amazonaws.com/amazon_linux/${ARM64_OR_AMD64}/latest/aws-otel-collector.rpm" -o /tmp/aws-otel-collector.rpm
dnf install -y /tmp/aws-otel-collector.rpm
rm /tmp/aws-otel-collector.rpm
/opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a start
/opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a stop

pip3 install -U \
	awscli

source /usr/local/ami_setup/shared/al2023/ssh-harden.sh

source /usr/local/ami_setup/shared/al2023/nitro-enclave.sh

mkdir -p /root/.docker
cp /usr/local/ami_setup/server_scripts/docker-config.json /root/.docker/config.json
mkdir -p /home/ec2-user/.docker
cp /usr/local/ami_setup/server_scripts/docker-config.json /home/ec2-user/.docker/config.json
chown -R ec2-user:ec2-user /home/ec2-user/.docker

cp /usr/local/ami_setup/server_scripts/docker-daemon.json /etc/docker/daemon.json
usermod -aG docker ec2-user

curl -fsSL https://tailscale.com/install.sh | sh

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
