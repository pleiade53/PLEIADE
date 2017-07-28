#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

IP=/sbin/ip
AWK=/bin/awk
CUT=/bin/cut
GREP=/bin/grep
ECHO=/usr/bin/echo
IFCONFIG=/sbin/ifconfig
IPTABLES=/sbin/iptables

# Network namespaces

# hub jail. Every namespace has a veth in the hub
HUB_JAIL=hub-jail

# Virtual interfaces names
IF_ETH=ifeth0
IF_VETH=veth-if
HOST_ETH=eth0
HOST_VETH=veth-host
BRIDGE_ETH=br0
NET_ETH=neteth0
NET_VETH=veth-net
NET_ETH=usbeth0
NET_VETH=veth-usb

# Virtual network adresses
NET_ADDR=10.0.3
NET_MASK=255.255.255.0
CIDR_MASK=24


# Interfaces for if-netns
IF_ETH_IP=$NET_ADDR.1
IF_VETH_IP=$NET_ADDR.10

BRIDGE_ETH_IP=$NET_ADDR.15

# Interfaces for root netns
HOST_ETH_IP=$NET_ADDR.2
HOST_VETH_IP=$NET_ADDR.20
BRIDGE_HOST_IP=$NET_ADDR.25

# Interfaces for containers
NET_VETH_IP=$NET_ADDR.3
USB_VETH_IP=$NET_ADDR.4


# Container launch scripts
LOC=/bin
LXC_PREFIX=launch-containers
START_HOST="$LOC/$LXC_PREFIX"-user.sh
START_NETWORK="$LOC/$LXC_PREFIX"-network.sh
START_USB="$LOC/$LXC_PREFIX"-usb.sh

# List physical interfaces
PHY_IFS_STR=$($IP link | $AWK -F': ' '{ print $2 }' | $GREP . | $GREP -v "lo")
PHY_IFS=(${PHY_IFS_STR[0]})

# Interfaces that has to be promiscuous (i.e. interfaces that can receive packet they aren't designated to)
# Every virtual interfaces in HUB_JAIL should be promiscuous as well as veth peers in physical jail
PROMISC_IF=( $IF_ETH $IF_VETH $HOST_VETH $NET_ETH $NET_VETH )

$ECHO "Physical interfaces on the machine:"

for interface in ${PHY_IFS[*]}; do
    $ECHO "    - $interface"
done

# Network namespaces aliases
IP_HUB_JAIL="$IP netns exec $HUB_JAIL"

$ECHO ""
$ECHO "Creating interfaces..."
$IP link add dev $HOST_ETH type veth peer name $HOST_VETH
$IP link add dev $IF_ETH type veth peer name $IF_VETH
$IP link add dev $NET_ETH type veth peer name $NET_VETH
$IP link add dev $USB_ETH type veth peer name $USB_VETH

for interface in ${PROMISC_IF[*]}; do
    # enable promiscuous mode for selected interfaces
    $IFCONFIG $interface promisc
done


$ECHO ""
$ECHO "Creating network namespaces..."
$IP netns add $HUB_JAIL
    # Add loopback interfaces
    $IP_HUB_JAIL $IP link set dev lo up

$ECHO ""
$ECHO "Isolating interfaces in namespaces..."
# Put interfaces where they belong
$IP link set dev $HOST_VETH netns $HUB_JAIL
$IP link set dev $IF_VETH netns $HUB_JAIL
$IP link set dev $NET_VETH netns $HUB_JAIL
$IP link set dev $USB_VETH netns $HUB_JAIL
for interface in ${PHY_IFS[*]}; do
    #enable promiscuous mode for physical interfaces
    $IFCONFIG $interface promisc
    $IP link set dev $interface netns $IF_JAIL
done

$ECHO ""
$ECHO "Connecting to bridge..."

$IP_HUB_JAIL $IP link add dev $BRIDGE_ETH type bridge
$IP_HUB_JAIL $IP link set dev $BRIDGE_ETH promisc on
$IP_HUB_JAIL $IP addr add $BRIDGE_ETH_IP/$CIDR_MASK dev $BRIDGE_ETH
$IP_HUB_JAIL $IP link set dev $BRIDGE_ETH up
$IP_HUB_JAIL $IP link set dev $HOST_VETH master $BRIDGE_ETH
$IP_HUB_JAIL $IP link set dev $IF_VETH master $BRIDGE_ETH
$IP_HUB_JAIL $IP link set dev $NET_VETH master $BRIDGE_ETH
$IP_HUB_JAIL $IP link set dev $USB_VETH master $BRIDGE_ETH

$ECHO ""
$ECHO "Setting interfaces addresses..."

$IP addr add $HOST_ETH_IP/$CIDR_MASK dev $HOST_ETH
$IP_HUB_JAIL $IP addr add $HOST_VETH_IP/$CIDR_MASK dev $HOST_VETH
$IP addr add $IF_ETH_IP/$CIDR_MASK dev $IF_ETH
$IP_HUB_JAIL $IP addr add $IF_VETH_IP/$CIDR_MASK dev $IF_VETH
$IP_HUB_JAIL $IP addr add $NET_VETH_IP/$CIDR_MASK dev $NET_VETH
$IP_HUB_JAIL $IP addr add $USB_VETH_IP/$CIDR_MASK dev $USB_VETH

$ECHO ""
$ECHO "Bringing up interfaces..."
$IP link set $HOST_ETH up
$IP_HUB_JAIL $IP link set $HOST_VETH up
$IP link set $IF_ETH up
$IP_HUB_JAIL $IP link set $IF_VETH up
$IP_HUB_JAIL $IP link set $NET_VETH up



$ECHO ""
$ECHO "Creating routes..."

$IP_HUB_JAIL $IP route add default via $NET_ADDR.31
$IP_HUB_JAIL $IP route del $NET_ADDR.0/$CIDR_MASK dev $IF_VETH
$IP_HUB_JAIL $IP route del $NET_ADDR.0/$CIDR_MASK dev $HOST_VETH
$IP_HUB_JAIL $IP route add $NET_ADDR.0/$CIDR_MASK dev $BRIDGE_ETH

$ECHO ""
$ECHO "Setting up firewall rules ..."

# ensure ip forwarding is set
$ECHO 1 > /proc/sys/net/ipv4/ip_forward

# Flush rules
	# TODO securize firewall rules
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P FORWARD DROP
$IPTABLES -t nat -F
$IPTABLES -F
$IP_HUB_JAIL $IPTABLES -P FORWARD DROP
$IP_HUB_JAIL $IPTABLES -F FORWARD
$IP_HUB_JAIL $IPTABLES -t nat -F



# TODO : Move this part to connection script
# Masquerade virtual network
for interface in ${PHY_IFS[*]}; do
    /sbin/dhclient $interface 
    $IPTABLES -t nat -A POSTROUTING -s $NET_ADDR.0/$NET_MASK -o $interface -j MASQUERADE
    # Allow forwarding both ways
    $IPTABLES -A FORWARD -i $interface -o $IF_ETH -j ACCEPT
    $IPTABLES -A FORWARD -o $interface -i $IF_ETH -j ACCEPT
done

$IP_HUB_JAIL $IPTABLES -A FORWARD -i $HOST_VETH -o $NET_VETH -j ACCEPT
$IP_HUB_JAIL $IPTABLES -A FORWARD -o $HOST_VETH -i $NET_VETH -j ACCEPT
$IP_HUB_JAIL $IPTABLES -A FORWARD -i $IF_VETH -o $NET_VETH -j ACCEPT
$IP_HUB_JAIL $IPTABLES -A FORWARD -o $IF_VETH -i $NET_VETH -j ACCEPT
$IPTABLES -A INPUT -s $NET_ADDR.0/$NET_MASK -j ACCEPT


# Launch the connection daemon
/bin/pleiade-network-connect.sh

# Launch containers
#	Formalism:
#	$(start script) $(hub contact point interface) $(netns bridge ip) $(corresponding netns name)
$ECHO "Starting network"
$START_NETWORK $NET_ETH &

$ECHO "Starting usb container"
$START_USB &

# Start host containers at the end
$ECHO "Sarting display"
/bin/chvt 2
$START_HOST $HOST_ETH $BRIDGE_HOST_IP/$CIDR_MASK








