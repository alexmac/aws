#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

mkdir -p /usr/local/ami_setup
cp -r /tmp/ubuntu_scripts /usr/local/ami_setup
cp -r /tmp/shared /usr/local/ami_setup

source /usr/local/ami_setup/shared/universal/arch.sh

apt-get update
apt-get -o DPkg::Lock::Timeout=30 update

pushd /tmp
wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/${CUDA_ARCH}/cuda-keyring_1.1-1_all.deb" -O cuda-keyring.deb
dpkg -i cuda-keyring.deb
rm cuda-keyring.deb
popd

apt-get upgrade -y
apt-get install -y python3-pip nala net-tools
apt-get upgrade -y
apt-get autoremove
apt-get clean
apt-get update

pip3 install -U --break-system-packages --ignore-installed \
	awscli pipenv

systemctl disable ModemManager

reboot
