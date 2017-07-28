#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

#### Install script for user container ####

DNF=/bin/dnf
CP=/bin/cp
ECHO=/bin/echo
RM=/bin/rm
CHMOD=/bin/chmod
MKDIR=/bin/mkdir
SYSCTL=/bin/systemctl
IPTABLES=/sbin/iptables
USERADD=/sbin/useradd
PASSWD=/bin/passwd
CHOWN=/bin/chown
CAT=/bin/cat

$DNF update
$ECHO "Installing components from repositories..."
$DNF group install lxde-desktop
$DNF install openssh-server langpacks-fr firefox zenity nfs-utils cockpit dbus-x11
$DNF remove firewalld

# configure network
$RM -f /etc/resolv.conf
$ECHO "nameserver 10.0.3.31" > /etc/resolv.conf

$ECHO "Installing scripts ..."
$CHMOD 755 -R /root/pleiade-user/scripts/
$CP -R /root/pleiade-user/scripts/bin/* /bin
$CP -R /root/pleiade-user/scripts/sbin/* /sbin


# configure network access to data
$ECHO "configuring usb access"
$MKDIR -p /media/DATA
$ECHO "# USB devices and DATA are accessed via nfs" >> /etc/fstab
$ECHO "10.0.3.41:/media /media/DATA nfs defaults,user,auto,noatime,intr 0 0" >> /etc/fstab


# Authorize X11 Forwarding
$CAT << EOF > /etc/ssh/sshd_config

Port 22
PermitRootLogin yes
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication yes
ChallengeResponseAuthentication no
PrintMotd no
Subsystem	sftp	/usr/lib/ssh/sftp-server
X11Forwarding yes

EOF

# Enable services
$ECHO "Enables services"
$SYSCTL enable sshd.service
$SYSCTL enable cockpit.socket
$SYSCTL start sshd
$SYSCTL start cockpit

# Setup admin
$ECHO "Creating admin user"
$USERADD pleiade-admin
$PASSWD pleiade-admin
$ECHO "Admin user is created. For now he has no rights whatsoever. We will configure this with cockpit"

# Setup kiosk user
$ECHO "Creating kiosk user"
$USERADD kiosk
$ECHO kiosk | $PASSWD kiosk --stdin

$MKDIR -p /etc/skel/Desktop

# Create internet connection and logout shortcuts

$ECHO -e "[Desktop Entry]\nEncoding=UTF-8\nType=Application\nName=Logout\nIcon=avatar-default\nExec=/bin/shutdown_req.sh\nStartupNotify=true\nCategory=System" > /etc/skel/Desktop/logout.desktop
$ECHO "" > /home/.shutdown_req
$CHMOD 766 /home/.shutdown_req

$ECHO -e "[Desktop Entry]\nEncoding=UTF-8\nType=Application\nName=Connect\nIcon=preferences-system-network\nExec=/bin/connect_req.sh\nStartupNotify=true\nCategory=System" > /etc/skel/Desktop/connect.desktop
$ECHO "" > /home/.con_req
$CHMOD 766 /home/.con_req
