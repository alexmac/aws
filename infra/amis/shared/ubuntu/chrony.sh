#!/bin/bash

# Use AWS NTP
echo "pool time.aws.com iburst" > /etc/chrony/sources.d/amazon-pool.sources
sed -i 's/^pool/# pool/g' /etc/chrony/chrony.conf
systemctl restart chronyd
