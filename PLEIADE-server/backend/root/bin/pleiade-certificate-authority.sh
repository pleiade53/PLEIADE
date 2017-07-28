#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

# Generates private key and signed certificate for it
# Arguments:
#	$1 : sign or revoke (required)
#	$2 : name of the certificate and key (required)
#	$3 : Unit name, ex: research_lab (optional)


calling_dir=$(/bin/pwd)
CD=/bin/cd
OPENSSL=/bin/openssl
MV=/bin/mv
MKDIR=/bin/mkdir
GREP=/bin/grep
AWK=/bin/awk
ECHO="/bin/echo -e"
RM=/bin/rm
CP=/bin/cp

CA_LOC=/root/certificate_authority

if [[ $# -lt 2 ]]
then
	$ECHO "Not enough arguments!"
	$ECHO "Usage:\n $0 [sign/revoke] [name] (Unit name)"
	exit
fi

if [[ $# -gt 3 ]]
then
	$ECHO "Too much arguments!"
	$ECHO "Usage:\n $0 [sign/revoke] [name] (Unit name)"
	exit
fi

if [ ! "$1" == "sign" ] && [ ! "$1" == "revoke" ]
then
	$ECHO "First argument must be either \"sign\" or \"revoke\""
	$ECHO "Usage:\n $0 [sign/revoke] [name] (Unit name)"
	exit
fi


# parse config
COUNTRY=$($GREP "CountryCode = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')
STATE=$($GREP "StateOrProvinceName = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')
CITY=$($GREP "CityName = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')
ORGANIZATION=$($GREP "OrganisationName = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')


if [ "$1" == "sign" ]
then
	$CD /root/certificate_authority
	$MKDIR -p "$calling_dir"/newcert/key
	$MKDIR -p "$calling_dir"/newcert/crt

	$OPENSSL req -nodes -newkey rsa:4096 -keyout "$2".key -out "$2".csr -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$3/CN=$2"

	# Sign the certificate request
	$OPENSSL ca -batch -out "$CA_LOC"/crt/"$2".crt -in "$2".csr -config "$CA_LOC"/ca.cnf
	# Move certificates somewhere else (we keep CA clean) 
	$MV "$2".key "$calling_dir"/newcert/key
	$MV "$CA_LOC"/crt/"$2".crt "$calling_dir"/newcert/crt
	$CP "$CA_LOC"/crt/ca.crt "$calling_dir"/newcert/crt
	# remove request
	$RM *.csr
	$CD $calling_dir
elif [ "$1" == "revoke" ]
then
	if [ -f "$2".crt ]
	then
		$MV "$2".crt "$CA_LOC"/crt
		$CD /root/certificate_authority
		$OPENSSL ca -config "$CA_LOC"/ca.cnf -revoke "$CA_LOC"/crt/"$2".crt
		# Recreate certificate revocation list
		$OPENSSL ca -config "$CA_LOC"/ca.cnf -gencrl -out crl/ca.crl
		$RM "$CA_LOC"/crt/"$2".crt
		$CD $calling_dir
	else
		$ECHO "$2.crt must be in the same directory ($calling_dir/$2.crt does not exist)"
		exit
	fi 
fi

