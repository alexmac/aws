#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

mkdir -p /usr/local/ami_setup
cp -r /tmp/tailscale_scripts /usr/local/ami_setup
cp -r /tmp/shared /usr/local/ami_setup

apt-get update
apt-get upgrade -y
apt-get update

apt-get install -y \
	python3-pip net-tools

pip3 install -U --break-system-packages --ignore-installed \
	awscli

source /usr/local/ami_setup/shared/ubuntu/ssh-harden.sh
source /usr/local/ami_setup/shared/ubuntu/chrony.sh

cp /usr/local/ami_setup/tailscale_scripts/startup.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/sign-ssh-host-key.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/sign-ssh-host-key.timer /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/01-cloud-init-custom.cfg /etc/cloud/cloud.cfg.d/

# Tailscale
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf

# https://tailscale.com/kb/1320/performance-best-practices#ethtool-configuration
printf '#!/bin/sh\n\nethtool -K %s rx-udp-gro-forwarding on rx-gro-list off \n' "$(ip route show 0/0 | cut -f5 -d" ")" | tee /etc/networkd-dispatcher/routable.d/50-tailscale
chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale
/etc/networkd-dispatcher/routable.d/50-tailscale

curl -fsSL https://tailscale.com/install.sh | sh

systemctl disable ModemManager
systemctl enable startup
systemctl enable sign-ssh-host-key.service
systemctl enable sign-ssh-host-key.timer

source /usr/local/ami_setup/shared/ubuntu/clean.sh
