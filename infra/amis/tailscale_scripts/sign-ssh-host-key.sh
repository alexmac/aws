#!/bin/bash -xe

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
IID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | base64 | tr -d '\n'`
IIDSIG=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/signature | tr -d '\n'`
HOST_KEY=`cat /etc/ssh/ssh_host_ed25519_key.pub`
echo "{\"host_pub_key\":\"$HOST_KEY\",\"instance_identity_doc\":\"$IID\",\"instance_identity_doc_signature\":\"$IIDSIG\"}" > calambda_request.json
aws lambda invoke --function-name calambda-ssh-host-key-signing --payload file://calambda_request.json calambda_response.json
cat calambda_response.json | jq -r .body.signed_host_key > /etc/ssh/ssh_host_ed25519_key.pub.certificate

echo "Add this to your known_hosts locally (modify * to match your ip ranges):"
cat calambda_response.json | jq -r .body.authorized_hosts_line
rm calambda_response.json calambda_request.json
