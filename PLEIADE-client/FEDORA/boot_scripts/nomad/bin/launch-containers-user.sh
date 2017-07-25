#!/bin/bash

ALCASAR_IP=$(/bin/grep "alcasar_server = " /var/lib/lxc/pleiade-network/rootfs/root/config/user.cfg | /bin/awk -F' = ' '{ print $2 }')

/bin/lxc-start -n pleiade-user
/bin/lxc-attach -n pleiade-user -- /bin/start-user.sh $ALCASAR_IP

while [ $(lxc-info -n pleiade-user | grep -c RUNNING) != 0 ]
do
	su -c "/bin/chvt 2; /bin/xinit /root/display.sh"
	
	/bin/killall Xorg
done

# User container has been powered off, shutdown the machine
/sbin/shutdown now
