#!/bin/bash -e

tailscale login \
    --auth-key `aws secretsmanager get-secret-value --secret-id tailscale | jq -r .SecretString` \
    --advertise-routes "172.31.0.0/16"
