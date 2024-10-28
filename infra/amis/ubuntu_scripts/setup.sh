#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

mkdir -p /usr/local/ami_setup
cp -r /tmp/ubuntu_scripts /usr/local/ami_setup
cp -r /tmp/shared /usr/local/ami_setup

source /usr/local/ami_setup/shared/universal/arch.sh

apt-get update

pushd /tmp
wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/${CUDA_ARCH}/cuda-keyring_1.1-1_all.deb" -O cuda-keyring.deb
dpkg -i cuda-keyring.deb
rm cuda-keyring.deb
popd

apt-get install -y nala
apt-get upgrade -y
apt-get autoremove
apt-get clean
apt-get update

systemctl disable ModemManager

reboot
