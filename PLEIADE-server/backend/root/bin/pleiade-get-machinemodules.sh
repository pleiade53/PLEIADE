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

if [[ $# -ne 1 ]]
then
	return
fi
MACHINE_IP=$($CAT /home/pleiade_installer/client_configs/"$1"/config/freelan/freelan.cfg | $GREP "ipv4_address_prefix_length" | $CUT -d'=' -f2 | $CUT -d'/' -f1)

for module in $($LS -l /var/www/html/ | $GREP -v "pvd" | $GREP "^d" | $AWK '{print $9}')
do
	if [[ ! -z $($GREP "$MACHINE_IP" /var/www/html/"$module"/.authorized_ip) ]]
	then
		$ECHO $module
	fi
done
