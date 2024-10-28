#!/bin/bash -e

exit_status=1
while [ $exit_status -ne 0 ]; do
    curl -s "http://169.254.169.254/" > /dev/null
    exit_status=$?
    sleep 1
done

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 30"`

AWS_REGION=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/region`
echo "export AWS_REGION=${AWS_REGION}" > /etc/profile.d/aws.sh
chmod a+r /etc/profile.d/aws.sh
aws configure set default.region $AWS_REGION
