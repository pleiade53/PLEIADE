#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

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
	
	$ECHO "AuthType Basic" >> /var/www/html/"$3"/.htaccess
	$ECHO "AuthName \"Please login\"" >> /var/www/html/"$3"/.htaccess
	$ECHO "AuthBasicProvider file" >> /var/www/html/"$3"/.htaccess
	$ECHO "AuthUserFile \"/var/www/html/pcc/.htpasswd\"" >> /var/www/html/"$3"/.htaccess
	$ECHO "AuthGroupFile \"/var/www/html/pcc/.htgroup\"" >> /var/www/html/"$3"/.htaccess
	$ECHO "<RequireAll>" >> /var/www/html/"$3"/.htaccess
	$ECHO "Require group $3" >> /var/www/html/"$3"/.htaccess
	# rebuild .htaccess to match the authorization
	auth_ip=$($CAT /var/www/html/"$3"/.authorized_ip)
	$ECHO "Require ip $auth_ip" >> /var/www/html/"$3"/.htaccess
	$ECHO "</RequireAll>">> /var/www/html/"$3"/.htaccess
else
	$ECHO "No module named $3"
fi
