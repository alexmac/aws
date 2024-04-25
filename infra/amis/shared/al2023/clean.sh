#!/bin/bash -e

yum clean all

[ -f /root/.ssh/authorized_keys ] && rm -f /root/.ssh/authorized_keys
[ -f /home/ec2-user/.ssh/authorized_keys ] && rm -f /home/ec2-user/.ssh/authorized_keys

find /var/log -type f | while read f; do echo -ne '' > $f; done

unset HISTFILE
[ -f /root/.bash_history ] && rm -f /root/.bash_history
[ -f /home/ec2-user/.bash_history ] && rm -f /home/ec2-user/.bash_history

echo 'Cleanup complete'
