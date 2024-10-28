#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/ami_setup
cp -r /tmp/eks_scripts /usr/local/ami_setup/
cp -r /tmp/shared /usr/local/ami_setup/

yum update
yum upgrade -y
yum update

yum install -y \
	jq ec2-instance-connect python3-pip \
	htop git vim aws-nitro-enclaves-cli \
	aws-nitro-enclaves-cli-devel wget dnsutils

pip3 install -U \
	awscli

source /usr/local/ami_setup/shared/al2023/ssh-harden.sh

source /usr/local/ami_setup/shared/al2023/nitro-enclave.sh

CRICTL_VERSION="v1.31.1"
pushd /tmp
wget "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARM64_OR_AMD64}.tar.gz" -O crictl.tar.gz
sudo tar zxvf crictl.tar.gz -C /usr/local/bin
rm crictl.tar.gz
cat <<'EOF' >> /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF
popd

cp /usr/local/ami_setup/eks_scripts/startup.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/al2023/sign-ssh-host-key.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/al2023/sign-ssh-host-key.timer /etc/systemd/system/

systemctl enable startup
systemctl enable sign-ssh-host-key.service
systemctl enable sign-ssh-host-key.timer

source /usr/local/ami_setup/shared/al2023/clean.sh
