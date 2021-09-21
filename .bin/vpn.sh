#!/usr/bin/bash
set -e
. /home/creio/.env

USER=cretm
SERVER=$oc
DNS=8.8.8.8

mv /etc/resolv.conf /etc/resolv.conf.sshuttle.bak
echo "nameserver $DNS" > /etc/resolv.conf
sshuttle --dns -r $USER@$SERVER -x $SERVER 0/0 || true
mv /etc/resolv.conf.sshuttle.bak /etc/resolv.conf
