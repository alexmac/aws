#!/bin/bash -e

apt-get clean all

[ -f /root/.ssh/authorized_keys ] && rm -f /root/.ssh/authorized_keys
[ -f /home/ubuntu/.ssh/authorized_keys ] && rm -f /home/ubuntu/.ssh/authorized_keys

find /var/log -type f | while read f; do echo -ne '' > $f; done

unset HISTFILE
[ -f /root/.bash_history ] && rm -f /root/.bash_history
[ -f /home/ubuntu/.bash_history ] && rm -f /home/ubuntu/.bash_history

echo 'Cleanup complete'
