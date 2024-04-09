#!/bin/bash -xe

exit_status=1
while [ $exit_status -ne 0 ]; do
    curl -s "http://169.254.169.254/" > /dev/null
    exit_status=$?
    sleep 1
done

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/user-data | bash -xe

bash /usr/local/ami_setup/server_scripts/sign-ssh-host-key.sh

xray -t 0.0.0.0:2000 -b 0.0.0.0:2000 &

