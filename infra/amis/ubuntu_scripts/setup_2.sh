#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

nala update
nala install -y \
	gcc git git-lfs ubuntu-drivers-common
nala install -y --no-install-recommends cuda-toolkit
nala install -y --no-install-recommends nvidia-gds cuda-drivers nvidia-cuda-toolkit
nala install -y --no-install-recommends libgl1-mesa-dev


curl -fsSL https://tailscale.com/install.sh | sh

curl -fsSL https://ollama.com/install.sh | sh

curl -LsSf https://astral.sh/uv/install.sh | sh

source /usr/local/ami_setup/shared/ubuntu/ssh-harden.sh
source /usr/local/ami_setup/shared/ubuntu/chrony.sh

cp /usr/local/ami_setup/ubuntu_scripts/startup.service /etc/systemd/system/
cp /usr/local/ami_setup/shared/ubuntu/01-cloud-init-custom.cfg /etc/cloud/cloud.cfg.d/

systemctl enable startup

source /usr/local/ami_setup/shared/ubuntu/clean.sh
