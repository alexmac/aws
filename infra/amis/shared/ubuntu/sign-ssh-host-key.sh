#!/bin/bash -xe

RESP_FILE=`mktemp --suffix=.json`
REQ_FILE=`mktemp --suffix=.json`
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 30"`
AWS_REGION=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/region`
aws configure set default.region $AWS_REGION
IID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | base64 | tr -d '\n'`
IIDSIG=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/signature | tr -d '\n'`
HOST_KEY=`cat /etc/ssh/ssh_host_ed25519_key.pub`
echo "{\"host_pub_key\":\"$HOST_KEY\",\"instance_identity_doc\":\"$IID\",\"instance_identity_doc_signature\":\"$IIDSIG\"}" > "${REQ_FILE}"
aws lambda invoke --function-name calambda-ssh-host-key-signing --payload "file://${REQ_FILE}" "${RESP_FILE}"
cat "${RESP_FILE}" | jq -r .body.signed_host_key > /etc/ssh/ssh_host_ed25519_key.pub.certificate

echo "Add this to your known_hosts locally (modify * to match your ip ranges):"
cat "${RESP_FILE}" | jq -r .body.authorized_hosts_line
rm "${RESP_FILE}"
rm "${REQ_FILE}"