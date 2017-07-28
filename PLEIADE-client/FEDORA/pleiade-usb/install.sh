#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

DNF=/bin/dnf
LXC_CREATE=/bin/lxc-create
LXC_COPY=/bin/lxc-copy
LXC_START=/bin/lxc-start
LXC_STOP=/bin/lxc-start
LXC_ATTACH=/bin/lxc-attach
ECHO=/bin/echo
GREP=/bin/grep
IP=/sbin/ip
DHCLIENT=/sbin/dhclient
CAT=/bin/cat

$DNF install lxc lxc-templates nfs-utils langpacks-fr gpg wget tar xz

$ECHO "Creating clean container"

$LXC_CREATE --name save --template download --dist fedora --release 25 --arch amd64
$IP link add dev lxcbr0 type bridge
$IP link set dev eth0 master lxcbr0
$DHCLIENT lxcbr0

$ECHO "Installing clamav in container"
$LXC_START --name save
$LXC_ATTACH --name save -- $DHCLIENT eth0
$LXC_ATTACH --name save -- $DNF install langpacks-fr clamav clamav-update
$CAT << EOF > /var/lib/lxc/save/rootfs/etc/freshclam.conf
UpdateLogFile /var/log/freshclam.log
LogTime yes
LogSyslog yes
DatabaseMirror db.FR.clamav.net
DatabaseMirror database.clamav.net
CompressLocalDatabase yes
ConnectTimeout 20
ReceiveTimeout 20
Bytecode yes
EOF

$LXC_ATTACH --name save -- /bin/freshclam
$LXC_STOP --name save

$ECHO "Completing analysis container configuration"
newconf=$($CAT /var/lib/lxc/save/config | $GREP -v "lxc.network.ipv4")
$ECHO "$newconf" > /var/lib/lxc/save/config

# configure ip adress of the container
$ECHO "lxc.network.ipv4 = 10.0.3.141/24 10.0.3.255" >> /var/lib/lxc/save/config
# Gateway is direct link (network trafic is only clamav update, no need to saturate VPN)
$ECHO "lxc.network.ipv4.gateway = 10.0.3.1" >> /var/lib/lxc/save/config

$ECHO "Configure usb data access"

$ECHO "/media 10.0.3.21(rw)" > /etc/exports

