#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

# Poll .shutdown_req for a connection request from user container
# Then launch connection editor on the screen

ZENITY=/bin/zenity
CAT=/bin/cat
GREP=/bin/grep
ECHO=/bin/echo
CUT=/bin/cut
IP=/sbin/ip
DHCLIENT=/sbin/dhclient

CON_POLL=/var/lib/lxc/pleiade-user/rootfs/home/.shutdown_req

export DISPLAY=:0


while true
do
	if [ -f $CON_POLL ]
	then
		con_type=$(/bin/tail -n1 $CON_POLL)
		if [ ! -z $con_type ] 
		then
			/bin/lxc-stop -n pleiade-user
			if [ "$CON_POLL" == "reboot" ]
			then
				/bin/lxc-start -n pleiade-user
			fi
			$ECHO "" > $CON_POLL
		fi
	fi
	/bin/sleep 1 
done
