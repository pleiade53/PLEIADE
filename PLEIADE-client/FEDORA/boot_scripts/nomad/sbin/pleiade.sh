#!/bin/bash
# chkconfig: 2345 99 01
# description: Jail every part in containers and finish by launching graphical interface


# Update time at each reboot
/sbin/iptables -I INPUT -m state --state ESTABLISHED -j ACCEPT
#/sbin/ntpdate pool.ntp.org

# Set up network namespaces and start containers
/bin/pleiade-create-jail.sh


stop()
{
	/bin/lxc-stop -n pleiade-user
	/bin/kill -9 $(/bin/pidof Xorg)
	shutdown now	
}

restart()
{
	stop
	start
}
