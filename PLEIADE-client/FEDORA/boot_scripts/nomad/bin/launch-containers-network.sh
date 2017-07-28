#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

IP=/sbin/ip
GREP=/bin/grep
#BRIDGE_NAME=netbr0

SUBUID=$($GREP "root" /etc/subuid | /bin/cut -d':' -f2)

# Allow tuntap devices in container
/bin/mknod /dev/tap c 10 200
/bin/chown $SUBUID:$SUBUID /dev/tap
/bin/mknod /dev/tun c 10 200
/bin/chown $SUBUID:$SUBUID /dev/tun

#Launch container
echo 0
/bin/lxc-start -n pleiade-network
echo 2
$IP link set dev $1 netns $3

echo "$IP link set dev $1 netns $3"
#Begin VPN
/bin/lxc-attach -n pleiade-network -- /bin/start-freelan-vpn.sh
