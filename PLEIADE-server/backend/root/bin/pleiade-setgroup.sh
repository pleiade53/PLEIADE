#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

CAT=/bin/cat
GREP=/bin/grep
AWK=/bin/awk
ECHO=/bin/echo

if [[ $# -gt 3 ]]
then
	$ECHO "Illegal number of arguments ! Usage:"
	$ECHO "$0 username groupname (unset)"
	exit
fi

if [[ $# -e 3 ]]
then
	if [ "$3" !=  "unset" ]
	then
		$ECHO "Usage:"
		$ECHO "$0 username groupname (unset)"
		exit
	fi

	group=$($GREP "$2:" /var/www/html/pcc/.htgroup | $AWK -F': ' '{ print $2 }')
	new_group=${group[@]/$1}

	htgroup_wo_group=$($GREP -v "$2:" /var/www/html/pcc/.htgroup)

	# Rewrite the group file with updated pleiade-administrators group
	$ECHO "$htgroup_wo_group" > /var/www/html/pcc/.htgroup
	$ECHO "$2: $new_group" >> /var/www/html/pcc/.htgroup
fi

if [[ $# -e 2 ]]
then

	group=$($GREP "$2:" /var/www/html/pcc/.htgroup | $AWK -F': ' '{ print $2 }')
	new_group=$("$group $1")

	htgroup_wo_group=$($GREP -v "$2:" /var/www/html/pcc/.htgroup)

	# Rewrite the group file with updated pleiade-administrators group
	$ECHO "$htgroup_wo_group" > /var/www/html/pcc/.htgroup
	$ECHO "$2: $new_group" >> /var/www/html/pcc/.htgroup

 fi
