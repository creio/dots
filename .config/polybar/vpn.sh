#!/usr/bin/sh

. /home/creio/.env

USER=cvc
SERVER=$uoc

# if (($(ps -aux | grep [p]icom | wc -l) > 0))


# if [[ $(ps -aux | grep "sshuttle" | wc -l) == 1 ]]; then
#   pkexec bash -c "sshuttle --dns -r $USER@$SERVER -x $SERVER 0/0 >/dev/null 2>&1 &"
#   polybar-msg hook vpn 2
# else
#   pkexec bash -c "pkill -9 sshuttle"
#   polybar-msg hook vpn 1
# fi


if [[ ! $(systemctl status wg-quick@wg0 | grep -i ": active" 2>/dev/null) ]]; then
  systemctl start wg-quick@wg0
  polybar-msg hook vpn 2
else
  systemctl stop wg-quick@wg0
  polybar-msg hook vpn 1
fi


# status=$(protonvpn status | head -n1 | awk '{print $2}')
# if [ "$status" == "Connected" ]; then
#   protonvpn d
#   echo "#90c861" > /tmp/vpnstat-hex
# else
#   protonvpn c
#   echo "#D35D6E" > /tmp/vpnstat-hex
# fi
