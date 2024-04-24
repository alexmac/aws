#!/bin/bash -e

pushd /actions-runner

REPO="alexmac/runner-test"
PAT=`aws secretsmanager get-secret-value --secret-id github/runner/registration | jq -r .SecretString`
REG_TOKEN=`curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${PAT}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${REPO}/actions/runners/registration-token"| jq -r .token`

sudo -u ubuntu ./config.sh \
	--url "https://github.com/${REPO}" \
	--unattended \
	--token "${REG_TOKEN}"

./svc.sh install ubuntu
./svc.sh start
