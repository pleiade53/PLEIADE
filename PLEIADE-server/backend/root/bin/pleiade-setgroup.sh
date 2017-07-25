#!/bin/bash

CAT=/bin/cat
GREP=/bin/grep
AWK=/bin/awk
ECHO=/bin/echo

if [[ $# -ne 2 ]]
then
	$ECHO "Illegal number of arguments ! Usage:"
	$ECHO "$0 username groupname"
	exit
fi

group=$($GREP "$2:" /var/www/html/pcc/.htgroup | $AWK -F': ' '{ print $2 }')
new_group=$("$group $1")

htgroup_wo_group=$($GREP -v "$2:" /var/www/html/pcc/.htgroup)

# Rewrite the group file with updated pleiade-administrators group
$ECHO "$htgroup_wo_group" > /var/www/html/pcc/.htgroup
$ECHO "$2: $new_group" >> /var/www/html/pcc/.htgroup

 
