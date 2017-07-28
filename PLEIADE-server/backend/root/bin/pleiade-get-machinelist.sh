#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

CAT=/bin/cat
LS=/bin/ls
GREP=/bin/grep
CUT=/bin/cut
AWK=/bin/awk
ECHO=/bin/echo

for machine in $($LS /home/pleiade_installer/client_configs/)
do
	ONLINE="false"
	MAC="$machine"
	IP=$($CAT /home/pleiade_installer/client_configs/"$machine"/config/freelan/freelan.cfg | $GREP "ipv4_address_prefix_length" | $CUT -d'=' -f2 | $CUT -d'/' -f1)
	if [[ -f /home/pleiade_installer/client_configs/"$machine"/.online ]]
	then
		ONLINE="true"
	fi
	$ECHO "$MAC ; $IP ; $ONLINE"
done
