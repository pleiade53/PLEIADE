#!/bin/bash

#### Install script for network container ####


DNF=/bin/dnf
ECHO=/bin/echo -e
SSH=/bin/ssh
SCP=/bin/scp
GREP=/bin/grep
CUT=/bin/cut
IP=/sbin/ip
CP=/bin/cp
TAR=/bin/tar
CHOWN=/bin/chown
CHMOD=/bin/chmod
SU=/bin/su
USERADD=/sbin/useradd
MKDIR=/bin/mkdir
IPTABLES=/sbin/iptables
NMAP=/bin/nmap
PING=/bin/ping

ARCH=$(/bin/uname -m)

$DNF update
$ECHO "Installing components from repositories..."
$DNF install openssh-server nmap
$ECHO "Installing custom rpm ..."
$DNF install /root/install/rpms/$ARCH/*
$CHMOD 700 -R /root/install/scripts
$CP -R /root/install/scripts/* /

MAC=$($IP link show neteth0 | $GREP ether | $CUT -d' ' -f6)

$ECHO "Connect as root to the pleiade master server from another computer and type: \n\t pleiade-setup-client.sh $MAC\n\n" 

while [ -z $server_ok ]
do
	$ECHO "Once that is done, enter the server ip address on the consultation network:"
	read server_ip
	ping_server=$($PING -c1 | $GREP "100% packet loss")
	if [ -z $ping_server ]
	then
		server_ok=1
	fi
done


$ECHO "Enter the server's ssh listening port (if you dont know, enter 22):"
read ssh_port

ssh_port_state=$($NMAP $server_ip -p $ssh_port | $GREP "ssh" | $CUT -d' ' -f2)
if [ "$ssh_port_state" != "open" ] 

# Retrieve config from master server
$SCP -p $ssh_port pleiade_installer@$server_ip:/home/pleiade_installer/client_configs/$MAC/config.tar.gz /root/config.tar.gz

$ECHO "Installing configuration ..."
$TAR -xf /root/ /root/config.tar.gz
# Prevent altering configuration from other than root
$CHOWN -R root:root /root/config
$CHMOD -R 600 /root/config


# Copy freelan config
$CP -f /root/config/freelan/freelan.cfg /etc/freelan/freelan.cfg

# Authorize freelan to connect to server
$CP /root/config/keys/ /etc/freelan/keys/
$CHMOD 640 -R /etc/freelan/keys/
$CHOWN root:root -R /etc/freelan/keys/


# Inside this folder are necessary keys for setting up ssh access to this container
$CP /root/config/.ssh /root/.ssh


# Authorize access only with public keys
$CAT << EOF > /etc/ssh/sshd_config

Port 4422
PermitRootLogin without-password
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
PrintMotd no
Subsystem	sftp	/usr/lib/ssh/sftp-server

EOF

$ECHO "enabling ip forwarding..."

newconf=$($GREP -v "net.ipv4.ip_forward" /etc/sysctl.conf)
$ECHO "$newconf" > /etc/sysctl.conf
$ECHO "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
/sbin/sysctl -p






