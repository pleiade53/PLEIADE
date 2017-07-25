#!/bin/bash

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

$DNF update
$ECHO "Installing components from repositories..."
$DNF install openssh-server lxde-desktop langpacks-fr firefox zenity nfs-utils cockpit
$DNF remove firewalld

# configure network
$RM -f /etc/resolv.conf
$ECHO "nameserver 10.0.3.31" > /etc/resolv.conf

$ECHO "Installing scripts ..."
$CHMOD 711 -R /root/install/scripts/
$CP -R /root/install/scripts/* /


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
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
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

$CAT << EOF > /etc/skel/Desktop/logout.desktop
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Logout
Icon=gnome-power-manager
Exec=/bin/shutdown_req.sh
StartupNotify=true
Category=System
EOF

$CAT << EOF > /etc/skel/Desktop/connect.desktop
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Connect
Icon=preferences-system-network
Exec=/bin/connect_req.sh
StartupNotify=true
Category=System
EOF





