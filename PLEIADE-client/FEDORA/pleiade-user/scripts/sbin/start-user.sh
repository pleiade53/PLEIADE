#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey


IPTABLES=/sbin/iptables
ECHO=/bin/echo
TOUCH=/bin/touch
CHMOD=/bin/chmod
CHOWN=/bin/chown


# N.A.C Gateway ip address is given as argument (and should be the DNS server)
$ECHO "nameserver $1" > /etc/resolv.conf

$IPTABLES -F
$IPTABLES -X
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT
# Allow established connection (required for tcp connection) and related (ex: active ftp)
$IPTABLES -I INPUT -m state --state ESTABLISHED -j ACCEPT
$IPTABLES -I INPUT -m state --state RELATED -j ACCEPT
# Allow connection from the VPN (already filtered by network container, so no need to be agressive here)
$IPTABLES -I INPUT -s 9.0.0.0/24 -j ACCEPT


# Setup polled files (communication between root and unprivilleged)
$TOUCH /home/.con_req
$TOUCH /home/.shutdown_req

$CHOWN root:root /home/.con_req
$CHOWN root:root /home/.shutdown_req

$CHMOD 622 /home/.con_req
$CHMOD 622 /home/.shutdown_req

# Launch logout file polling
/bin/unpriv-shutdown.sh
