#!/bin/bash

dnf check-release-update
LATEST_VERSION=$(cat /etc/motd  | grep Version | sed -n 's/.*Version \(.*\):/\1/p' | sort | tail -n 1)

if [ "$LATEST_VERSION" != "" ]; then
	echo "updating to $LATEST_VERSION"
    dnf upgrade -y --releasever=$LATEST_VERSION
    dnf check-release-update
    /usr/sbin/update-motd
fi
