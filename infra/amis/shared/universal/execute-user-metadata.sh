#!/bin/bash -e

exit_status=1
while [ $exit_status -ne 0 ]; do
    curl -s "http://169.254.169.254/" > /dev/null
    exit_status=$?
    sleep 1
done

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 30"`

if [ $(curl -s -o /dev/null -w '%{http_code}' -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data) -eq 200 ]; then
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/user-data | bash -xe
fi
