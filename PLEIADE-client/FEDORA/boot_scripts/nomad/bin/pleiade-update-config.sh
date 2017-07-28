#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

CP=/bin/cp
CAT=/bin/cat
ECHO=/bin/echo
DATE=/bin/date
CHMOD=/bin/chmod
# Check every 10min if a config update has been pushed by the server
CURRENT_CHECKSUM=$(/bin/sha256sum /var/lib/lxc/pleiade-network/rootfs/config.tar.gz)
export DISPLAY=:0

# Update log with each update check
LOG_COLLECTOR=/var/lib/lxc/pleiade-network/rootfs/root/log_collector

# Arbitrary wait 10 min for connexion with server to be established
/bin/sleep 600

while true
do
	# Append the daily log file with analysis data, server will retrieve it on its own
	$CAT /var/log/usb_log.txt >> "$LOG_COLLECTOR"/$($DATE +%d-%m-%y_usb.log)
	# Ensure container has the right to read the logfile
	$CHMOD 644 -R $LOG_COLLECTOR
	# Clean the usb analysis log file (everything is kept on the server)
	ECHO "" > /var/log/usb_log.txt
	
	TESTED_CHECKSUM=$(/bin/sha256sum /var/lib/lxc/pleiade-network/rootfs/config.tar.gz)
	if [ ! $CURRENT_CHECKSUM -eq $TESTED_CHECKSUM ]
	then
		CURRENT_CHECKSUM=$TESTED_CHECKSUM
		/bin/zenity --info --title="Update" --text="A configuration update has been installed, system will apply it in 3 min, save everything !" &
		sleep 180
		/bin/lxc-attach -n pleiade-user -- /sbin/shutdown -r now				
	fi
	# wait 10min before checking again
	/bin/sleep 600
done
