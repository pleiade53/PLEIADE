#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

# Generate freelan config for a client
# Arguments
#	$1: Name of the client (usually mac address)

GREP=/bin/grep
AWK=/bin/awk
CAT=/bin/cat
TAIL=/bin/tail
ECHO=/bin/echo

if [ $# -ne 1 ]
then
	$ECHO "ERROR - Invalid number of arguments"
	exit
fi

# Contact when inside the consulting network
PLEIADE_IP=$($GREP "PleiadeLocalAddress = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')
# Distant contact
PUBLIC_IP=$($GREP "PublicAddress = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')

nb_client=$($TAIL -n1 /root/nb_client)
new_client_nb=$(($nb_client+1))

if [[ $nb_client -gt 253 ]]
then
	$ECHO "ERROR - Pleiade can't handle more clients (for the moment)"
	exit
fi 

$CAT << EOF
[fscp]
listen_on=0.0.0.0:12000
contact=$PUBLIC_IP:12000
contact=$PLEIADE_IP:12000
cipher_capability=aes256-gcm
elliptic_curve_capability=secp521r1

[tap_adapter]
ipv4_address_prefix_length=9.0.0.$new_client_nb/24

[router]
client_routing_enabled=yes
accept_routes_requests=yes
system_route_acceptance_policy=any_with_gateway
internal_route_acceptance_policy=any
maximum_routes_limit=0
dns_servers_acceptance_policy=any

[security]
signature_certificate_file=/etc/freelan/keys/crt/$1.crt
signature_private_key_file=/etc/freelan/keys/key/$1.key
authority_certificate_file=/etc/freelan/keys/crt/ca.crt

EOF

$ECHO $new_client_nb > /root/nb_client
