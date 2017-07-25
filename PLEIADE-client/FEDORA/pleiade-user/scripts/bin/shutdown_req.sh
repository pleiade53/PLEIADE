#!/bin/bash

ECHO=/bin/echo
ZENITY=/bin/zenity

$ZENITY --question --title="Logout" --text="What do you want to do?" --ok-label="Shutdown" --cancel-label="Logout"

if [ $? -eq 0 ]
then
	$ECHO "poweroff" > /home/.shutdown_req
else
	$ECHO "reboot" > /home/.shutdown_req
fi
