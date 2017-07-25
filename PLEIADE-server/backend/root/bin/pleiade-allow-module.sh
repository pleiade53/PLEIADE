#!/bin/bash


# Allow or disallow access to a module
# Arguments
#	$1 : allow/disallow
#	$2 : machine IP@
#	$3 : module

ECHO=/bin/echo
GREP=/bin/grep
CAT=/bin/cat

IFS=$'\n'

if [ -d /var/www/html/"$3" ]
then
	if [ "$1" == "allow" ]
	then
		$ECHO "$2" >> /var/www/html/"$3"/.authorized_ip
	elif [ "$1" == "disallow" ]
	then
		AUTH_LIST=$($GREP -v "$2" /var/www/html/"$3"/.authorized_ip)
		$ECHO "$AUTH_LIST" > /var/www/html/"$3"/.authorized_ip
	fi
	
	$ECHO "Require all denied" > /var/www/html/"$3"/.htaccess
	# rebuild .htaccess to match the authorization
	for auth_ip in $($CAT /var/www/html/"$3"/.authorized_ip)
	do
		$ECHO "Require ip $auth_ip" >> /var/www/html/"$3"/.htaccess
	done
	
else
	$ECHO "No module named $3"
fi
