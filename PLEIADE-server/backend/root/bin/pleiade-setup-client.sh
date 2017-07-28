#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

# Declare a new or revoke an old pleiade machine and generate its configuration
# Arguments:
#	$1: Name of the machine (Usually MAC address)
#	$2: allowed modules list (/!\ be sure to put the list between quotes /!\) or delete
#	$3: Machine config (or nothing if we delete it)

ECHO=/bin/echo
CD=/bin/cd
PLEIADE_CA=/bin/pleiade-certificate-authority.sh
PLEIADE_MODULES=/bin/pleiade-allow-module.sh
PLEIADE_FREELAN=/bin/pleiade-freelan-configurator.sh
PLEIADE_USER=/bin/pleiade-user-configurator.sh
MKDIR=/bin/mkdir
CHMOD=/bin/chmod
CHOWN=/bin/chown
TAIL=/bin/tail
RM=/bin/rm
CAT=/bin/cat
GREP=/bin/grep
AWK=/bin/awk
MV=/bin/mv
TAR=/bin/tar

CONFIG_DIR=/home/pleiade_installer/client_configs

calling_dir=$(/bin/pwd)
if [[ $# -lt 2 ]]
then
	$ECHO "Illegal number of arguments"
	$ECHO "Usage:"
	$ECHO "$0 MAC_ADDRESS \"module1 module2 ...\"/delete [if creating: \"kiosk/user true/false (url)\" (unit name)"
	exit
fi

if [ "$2" == "delete" ]
then
	CLIENT_IP=$($GREP "ipv4_address_prefix_length=" "$CONFIG_DIR/$1"/config/freelan/freelan.cfg | $AWK -F'_length=' '{print $2}')
	for module in $($CAT "$CONFIG_DIR/$1"/auth_modules)
	do
		$PLEIADE_MODULES disallow $CLIENT_IP $module
	done
	$CP "$CONFIG_DIR"/"$1"/config/keys/crt/"$1".crt ./
	# revoke certificate
	$PLEIADE_CA revoke "$1"
	$CD $calling_dir
	$RM -Rf /home/pleiade_installer/client_configs/$1
	# Decrease client number in order for the IP to be reattributed
	nb_client=$($TAIL -n1 /root/nb_client)
	new_client_nb=$(($nb_client-1))
	$ECHO $new_client_nb > /root/nb_client
else
	if [[ $# -gt 4 ]]
	then
		$ECHO "Illegal number of arguments"
		$ECHO "Usage:"
		$ECHO "$0 MAC_ADDRESS \"module1 module2 ...\"/delete [if creating: \"kiosk/user true/false (url)\"(unit name)"
		exit
	fi
	i=0
	USER_MODE=""
	USER_CON=""
	USER_URL=""
	for user_arg in $3
	do
		if [[ $i -eq 0 ]]
		then
			USER_MODE=$user_arg
		elif [[ $i -eq 1 ]]
		then
			USER_CON=$user_arg
		elif [[ $i -eq 2 ]]
		then
			USER_URL="--kiosk-url=$user_arg"
		fi
		i=$(($i+1))
	done
	
	$MKDIR -p "$CONFIG_DIR/$1"
	$MKDIR -p "$CONFIG_DIR/$1"/config/
	$MKDIR -p "$CONFIG_DIR/$1"/config/freelan
	$MKDIR -p "$CONFIG_DIR/$1"/config/keys	
	
	# Sign certificate
	$PLEIADE_CA sign $1 $4
	$MV ./newcert/* "$CONFIG_DIR/$1"/config/keys
	
	# Generate user config
	$PLEIADE_USER --mode=$USER_MODE --con_req=$USER_CON $USER_URL > "$CONFIG_DIR/$1"/config/user.cfg
	
	$PLEIADE_FREELAN $1 > "$CONFIG_DIR/$1"/config/freelan/freelan.cfg
	
	CLIENT_IP=$($GREP "ipv4_address_prefix_length=" "$CONFIG_DIR/$1"/config/freelan/freelan.cfg | $AWK -F'_length=' '{print $2}')
	
	$ECHO "" > "$CONFIG_DIR/$1"/auth_modules
	for module_arg in $2
	do
		$PLEIADE_MODULES allow $CLIENT_IP $module_arg
		$ECHO "$module_arg" >> "$CONFIG_DIR/$1"/auth_modules
	done
	
	# Compress everything in one tarball that will be retrieved by the client
	$CP -R "$CONFIG_DIR/$1"/config ./
	$TAR -czf "$CONFIG_DIR/$1"/config.tar.gz config
	$RM -Rf config
	# Allow pleiade_installer to read this folder, but only root can modify config
	$CHMOD 640 -R $CONFIG_DIR
	$CHOWN root:pleiade_installer -R $CONFIG_DIR
	$RM -Rf ./newcert
fi

