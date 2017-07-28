#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

ALCASAR_IP=$(/bin/grep "alcasar_server = " /var/lib/lxc/pleiade-network/rootfs/root/config/user.cfg | /bin/awk -F' = ' '{ print $2 }')

/bin/lxc-start -n pleiade-user
/bin/lxc-attach -n pleiade-user -- /bin/start-user.sh $ALCASAR_IP

/bin/pleiade-network-connection.sh &

while [ $(lxc-info -n pleiade-user | grep -c RUNNING) != 0 ]
do
	su -c "/bin/chvt 2; /bin/xinit /root/display.sh"
	
	/bin/kill $(/bin/pidof Xorg)
done

# User container has been powered off, shutdown the machine
/sbin/shutdown now
