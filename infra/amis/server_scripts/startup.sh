#!/bin/bash -xe

source /usr/local/ami_setup/shared/universal/configure-aws-region.sh

bash /usr/local/ami_setup/shared/al2023/sign-ssh-host-key.sh

tailscale up \
    --authkey `aws secretsmanager get-secret-value --secret-id tailscale/server | jq -r .SecretString` \
    --ssh

xray -t 0.0.0.0:2000 -b 0.0.0.0:2000 &

source /usr/local/ami_setup/shared/universal/execute-user-metadata.sh

