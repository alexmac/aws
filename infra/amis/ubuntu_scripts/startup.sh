#!/bin/bash -e

source /usr/local/ami_setup/shared/universal/configure-aws-region.sh

tailscale up \
    --auth-key `aws secretsmanager get-secret-value --secret-id tailscale/server | jq -r .SecretString` \
    --ssh
