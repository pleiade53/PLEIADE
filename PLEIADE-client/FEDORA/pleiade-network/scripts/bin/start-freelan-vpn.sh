#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

GREP=/bin/grep
IPTABLES=/sbin/iptables
IP=/sbin/ip
AWK=/bin/awk

# retrieve config

# Public IP address of the pleiade server
DISTANT_CONTACT=$($GREP "pleiade_server_public = " /root/config/user.cfg | $AWK -F' = ' '{ print $2 }')
# Address of pleiade server on the consulting network
LOCAL_CONTACT=$($GREP "pleiade_server_local = " /root/config/user.cfg | $AWK -F' = ' '{ print $2 }')


# Setup firewall for the container
$IPTABLES -F
$IPTABLES -X
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -I INPUT -s 10.0.3.0/24 -j ACCEPT
$IPTABLES -I INPUT -s 9.0.0.0/24 -j ACCEPT
$IPTABLES -I INPUT -s 10.0.3.0 -p tcp --dport 4422 -j DROP
$IPTABLES -I INPUT -s $DISTANT_CONTACT -j ACCEPT
$IPTABLES -I INPUT -s $LOCAL_CONTACT -j ACCEPT

# create routes only to pleiade server
$IP route del default
$IP route add $DISTANT_CONTACT via 10.0.3.1
$IP route add $LOCAL_CONTACT via 10.0.3.1


/usr/bin/freelan -d

# Masquerade all connections going through VPN
$IPTABLES -t nat -I POSTROUTING -s 10.0.3.0/24 -o tap0 -j MAQUERADE

