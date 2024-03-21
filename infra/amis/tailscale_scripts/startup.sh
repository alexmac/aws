#!/bin/bash -e

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
MAC=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/network/interfaces/macs | sed -e 's/\///'`
VPC_CIDR=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-ipv4-cidr-block`

tailscale login \
    --auth-key `aws secretsmanager get-secret-value --secret-id tailscale | jq -r .SecretString` \
    --advertise-routes "$VPC_CIDR"
