#!/bin/bash -e

apt-get clean all

[ -f /root/.ssh/authorized_keys ] && rm -f /root/.ssh/authorized_keys
[ -f /home/admin/.ssh/authorized_keys ] && rm -f /home/admin/.ssh/authorized_keys

find /var/log -type f | while read f; do echo -ne '' > $f; done

unset HISTFILE
[ -f /root/.bash_history ] && rm -f /root/.bash_history
[ -f /home/admin/.bash_history ] && rm -f /home/admin/.bash_history

echo 'Cleanup complete'
