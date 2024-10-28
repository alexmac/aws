#!/bin/bash -e

source /usr/local/ami_setup/shared/universal/configure-aws-region.sh

MAC=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/network/interfaces/macs | sed -e 's/\///'`
VPC_CIDR=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-ipv4-cidr-block`

tailscale login \
    --auth-key `aws secretsmanager get-secret-value --secret-id tailscale | jq -r .SecretString` \
    --ssh --advertise-routes "$VPC_CIDR"
