#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

ECHO=/bin/echo
HTPASSWD=/bin/htpasswd
CAT=/bin/cat
RM=/bin/rm
AWK=/bin/awk
MKDIR=/bin/mkdir

if [[ $# -ne  2 ]]
then
	$ECHO "Illegal argument number"
	$ECHO "Usage:"
	$ECHO "$0 add/del/mod \"username=UserToManipulate password=NewPassword [add/del]_module=ModuleName1 [add/del]_module=ModuleName2 [...]\""
fi

USERNAME=""
PASSWORD=""
MODULE_ADDLIST=()
MODULE_DELLIST=()

# Parse argument list
for param in $2
do
	if [[ "$param" == "username="* ]]
	then
		USERNAME=$($ECHO "$param" | $AWK -F'username=' '{print $2}')
	elif [[ "$param" == "password="* ]]
	then
		PASSWORD=$($ECHO "$param" | $AWK -F'password=' '{print $2}')
	elif [[ "$param" == "addmodule="* ]]
	then
		MODULE_ADDLIST+=($($ECHO "$param" | $AWK -F'addmodule=' '{print $2}'))
	elif [[ "$param" == "delmodule="* ]]
	then
		MODULE_DELLIST+=($($ECHO "$param" | $AWK -F'delmodule=' '{print $2}'))
	fi
done

if [ "$1" == "add" ]
then
	# Create a new user using htpasswd
	$HTPASSWD -b /var/www/html/pcc/.htpasswd $USERNAME $PASSWORD
	# Add modules
	$MKDIR -p /var/www/html/pvd/"$USERNAME"
	for module in ${MODULE_ADDLIST[@]}
	do
		$ECHO "$module" >> /var/www/html/pvd/"$USERNAME"/modules_list
		/bin/pleiade-setgroup.sh $USERNAME $module
	done
	
	# Needs either user account or admin account
$CAT << EOF > /var/www/html/pvd/"$USERNAME"/.htaccess

AuthName "User space, requires authentication"
AuthType Basic
AuthUserFile "/var/www/html/pcc/.htpasswd"
Require user $USERNAME
Require group pcc

EOF

	
elif [ "$1" == "del" ]
then
	# Simply remove it from auth file and delete his userspace
	$HTPASSWD -D /var/www/html/pcc/.htpasswd $USERNAME
	$RM -Rf /var/www/html/pvd/"$USERNAME"
elif [ "$1" == "mod" ]
then
	# If a new password has been specified
	if [[ ! -z $PASSWORD ]]
	then
		$HTPASSWD -b /var/www/html/pcc/.htpasswd $USERNAME $PASSWORD
	fi
	MODULE_EXISTING=()
	for module in $($CAT /var/www/html/pvd/"$USERNAME"/modules_list)
	do
		MODULE_EXISTING+=($module)
	done
	for module in ${MODULE_ADDLIST[@]}
	do
		# Don't add it if it already is in the list
		if [[ ! " ${MODULE_EXISTING[@]} " =~ " ${module} " ]]
		then
    		MODULE_EXISTING+=($module)
		fi		
	done
	
	for del in ${MODULE_DELLIST[@]}
	do
	   MODULE_EXISTING=("${MODULE_EXISTING[@]/$del}")
	done
	
	$ECHO "" > /var/www/html/pvd/"$USERNAME"/modules_list
	for module in ${MODULE_EXISTING[@]}
	do
		$ECHO "$module" >> /var/www/html/pvd/"$USERNAME"/modules_list
	done
fi
