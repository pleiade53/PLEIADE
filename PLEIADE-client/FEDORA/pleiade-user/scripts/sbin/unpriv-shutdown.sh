#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

# Poll .shutdown_req file every seq
# If "poweroff" is inside the file, shutdown the container (and then shutdown the machine)
# If "reboot", restart the container (effectively login out of the user container)

TAIL=/bin/tail
ECHO=/bin/echo
TOUCH=/bin/touch
CHMOD=/bin/chmod
SHUTDOWN=/sbin/shutdown
SLEEP=/bin/sleep

POLL_FILE=/home/.shutdown_req

while true
do
	if [ -f $POLL_FILE ]
	then
		ACTION=$($TAIL -n 1 $POLL_FILE)
		$ECHO "" > $POLL_FILE
		if [ "$ACTION" == "poweroff" ]
		then
			$SHUTDOWN now
		elif [ "$ACTION" == "reboot" ]
		then
			$SHUTDOWN -r now
		fi
	else
		$TOUCH $POLL_FILE
	fi
	$SLEEP 1
done
