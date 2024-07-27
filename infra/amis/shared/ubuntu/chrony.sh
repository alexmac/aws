#!/bin/bash

# Use AWS NTP
sed -i 's/^pool/# pool/g' /etc/chrony/chrony.conf
echo "pool time.aws.com iburst" > /etc/chrony/sources.d/amazon-pool.sources
systemctl restart chronyd
