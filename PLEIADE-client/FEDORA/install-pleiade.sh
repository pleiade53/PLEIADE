#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

DNF=/bin/dnf
LXC_CREATE=/bin/lxc-create
LXC_COPY=/bin/lxc-copy
LXC_START=/bin/lxc-start
LXC_STOP=/bin/lxc-stop
LXC_ATTACH=/bin/lxc-attach
TAIL=/bin/tail
ECHO="/bin/echo -e"
CUT=/bin/cut
CAT=/bin/cat
CP=/bin/cp
CHMOD=/bin/chmod
CHOWN=/bin/chown
TAR=/bin/tar
IP=/sbin/ip
DHCLIENT=/sbin/dhclient
GREP=/bin/grep
AWK=/bin/awk
PING=/bin/ping
SYSTEMCTL=/bin/systemctl

TEST_CHECK=0
create_container(){
	$LXC_CREATE --name $1 --template download -- --no-validate --dist fedora --release 25 --arch amd64
}

copy_container(){
	$LXC_COPY --name $1 --newname $2
}

copy_in_container()
{
	$ECHO "copying $2 in container $1"
	$CP -R "$2" /var/lib/lxc/"$1"/rootfs/"$3"
	root_subuid=$($CAT /etc/subuid | $GREP "root:" | $CUT -d':' -f2)
	root_subgid=$($CAT /etc/subgid | $GREP "root:" | $CUT -d':' -f2)
	$ECHO "changing owner to match container subuid"
	$CHOWN -R $root_subuid:$root_subgid /var/lib/lxc/"$1"/rootfs/"$3"
}


#To install and configure a container, provide an archive container_name.tar.gz containing every install script and binaries and a file named install.sh at root
install_container(){
	$TAR -xf "$1".tar.gz
	copy_in_container "$1" "$1" "root"	
	$LXC_START --name $1
	$LXC_ATTACH --name $1 -- $DHCLIENT enp0s3
	$LXC_ATTACH --name $1 -- $CHMOD +x /root/"$1"/install.sh
	$LXC_ATTACH --name $1 -- /root/"$1"/install.sh
	$LXC_STOP --name $1
}

prerequisites(){
	$ECHO "installing lxc ..."
	# install lxc (containers), sshpass (no prompt for password with ssh), feh (draw background image), zenity (gtk dialogs) 
	$DNF install gpg wget lxc lxc-templates sshpass feh zenity ntp net-tools nm-connection-editor
	$DNF group install base-x
	$ECHO "enabling ip forwarding..."
	
	newconf=$($GREP -v "net.ipv4.ip_forward" /etc/sysctl.conf)
	$ECHO "$newconf" > /etc/sysctl.conf
	$ECHO "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
	/sbin/sysctl -p
	
	$ECHO "setting up subuids and subgids ..."
	# configure unprivilleged mode
	last_subuid=$($TAIL -n 1 /etc/subuid | $CUT -d':' -f2)
	last_subgid=$($TAIL -n 1 /etc/subgid | $CUT -d':' -f2)
	
	uoffset=$($TAIL -n 1 /etc/subuid | $CUT -d':' -f2)
	goffset=$($TAIL -n 1 /etc/subgid | $CUT -d':' -f2)
	
	new_subuid=$((last_subuid + uoffset))
	new_subgid=$((last_subgid + goffset))

	#write subuid and subgid mapping for system
	$ECHO "root:$new_subuid:65536" >> /etc/subuid
	$ECHO "root:$new_subgid:65536" >> /etc/subgid
	$ECHO "root user --> $new_subuid"
	$ECHO "root group --> $new_subgid"
	
	$ECHO "writing lxc default conf ..."
	#edit lxc default config
$CAT << EOF > /etc/lxc/default.conf
lxc.network.type = phys
lxc.network.link = enp0s3
lxc.id_map = u 0 $new_subuid 65536
lxc.id_map = g 0 $new_subgid 65536

EOF
	
	$ECHO "Removing firewalld (we use netfilter)"
	$DNF remove firewalld
	
	# We deal with certificates, time is of the essence
	$SYSTEMCTL enable ntpd
	/sbin/ntpdate pool.ntp.org
	$SYSTEMCTL start ntpd

	/bin/ssh-keygen
		
}

nomad_mode()
{
	root_subuid=$($CAT /etc/subuid | $GREP "root:" | $CUT -d':' -f2)
	root_subgid=$($CAT /etc/subgid | $GREP "root:" | $CUT -d':' -f2)e
	
	$ECHO "creating network container"
	create_container "pleiade-network" 
	install_container "pleiade-network"
	
	
	# Write final configuration of the network container
	newconf=$($CAT /var/lib/lxc/pleiade-network/config | $GREP -v "lxc.network.ipv4" | $GREP -v "lxc.network.link" | $GREP -v "lxc.network.type")
	$ECHO "$newconf" > /var/lib/lxc/pleiade-network/config
	$ECHO "lxc.network.type = phys" >> /var/lib/lxc/pleiade-network/config
	$ECHO "lxc.network.link = neteth0" >> /var/lib/lxc/pleiade-network/config
	$ECHO "lxc.network.flags = up" >> /var/lib/lxc/pleiade-network/config
	$ECHO "lxc.network.ipv4 = 10.0.3.31/24 10.0.3.255" >> /var/lib/lxc/pleiade-network/config
	$ECHO "lxc.network.ipv4.gateway = 10.0.3.1" >> /var/lib/lxc/pleiade-network/config
	$ECHO "lxc.mount.entry = /dev/tap dev/net/tap none bind,create=file" >> /var/lib/lxc/pleiade-network/config
	$ECHO "lxc.mount.entry = /dev/tun dev/net/tun none bind,create=file" >> /var/lib/lxc/pleiade-network/config

	
	
	$ECHO "creating user container"
	create_container "pleiade-user"
	install_container "pleiade-user"
	
	
	# Write final configuration of the user container
	newconf=$($CAT /var/lib/lxc/pleiade-user/config | $GREP -v "lxc.network.ipv4" | $GREP -v "lxc.network.link" | $GREP -v "lxc.network.type")
	$ECHO "$newconf" > /var/lib/lxc/pleiade-user/config
	$ECHO "lxc.network.type = phys" >> /var/lib/lxc/pleiade-user/config
	$ECHO "lxc.network.link = eth0" >> /var/lib/lxc/pleiade-user/config
	$ECHO "lxc.network.flags = up" >> /var/lib/lxc/pleiade-user/config
	$ECHO "lxc.network.ipv4 = 10.0.3.21/24 10.0.3.255" >> /var/lib/lxc/pleiade-user/config
	$ECHO "lxc.network.ipv4.gateway = 10.0.3.31" >> /var/lib/lxc/pleiade-user/config
	
	
	$ECHO "creating usb container"
	create_container "pleiade-usb"
	install_container "pleiade-usb"
	
	# Write final configuration of the usb container
	newconf=$($CAT /var/lib/lxc/pleiade-usb/config | $GREP -v "lxc.network.ipv4" | $GREP -v "lxc.network.link" | $GREP -v "lxc.network.type")
	$ECHO "$newconf" > /var/lib/lxc/pleiade-usb/config
	$ECHO "lxc.network.type = phys" >> /var/lib/lxc/pleiade-usb/config
	$ECHO "lxc.network.link = usbeth0" >> /var/lib/lxc/pleiade-usb/config
	$ECHO "lxc.network.flags = up" >> /var/lib/lxc/pleiade-usb/config	
	$ECHO "lxc.network.ipv4 = 10.0.3.41/24 10.0.3.255" >> /var/lib/lxc/pleiade-usb/config
	$ECHO "lxc.network.ipv4.gateway = 10.0.3.31" >> /var/lib/lxc/pleiade-usb/config
	
	$CHMOD -R 711 $(pwd)/boot_scripts/nomad
	$CP -R $(pwd)/boot_scripts/nomad/bin/* /bin
	$CP -R $(pwd)/boot_scripts/nomad/sbin/* /sbin
	$CP -R $(pwd)/boot_scripts/nomad/root/* /root
}

testing()
{
	release=$(uname -r)
	if [[ ! "$release" == *"fc25"* ]]
	then
		$ECHO "Sorry, for now, PleiadeOS can only be installed on a fedora 25 base ..."
		return
	fi
	
	#mirrors_con_check=$($PING -c1 mirrors.fedoraproject.com)
	#download_con_check=$($PING -c1 download.fedoraproject.com)
	#lxcgpg_con_check=$($PING -c1 pool.sks-keyservers.net)
	#lxcdownload_con_check=$($PING -c1 uk.images.linuxcontainers.org)
	
	
	con_check=0
	if [[ "$mirrors_con_check" == *"1 packets transmitted, 1 received"* ]]
	then
		$ECHO "Mirrors server OK"
		con_check=$con_check+1
	else
		$ECHO "Fedora mirrors server unreachable !!"
	fi
	
	if [[ "$download_con_check" == *"1 packets transmitted, 1 received"* ]]
	then
		$ECHO "Download server OK"
		con_check=$con_check+1
	else
		$ECHO "Fedora download server unreachable !!"
	fi
	
	if [[ "$lxcgpg_con_check" == *"1 packets transmitted, 1 received"* ]]
	then
		$ECHO "LXC GPG keys server OK"
		con_check=$con_check+1
	else
		$ECHO "LXC GPG keys server unreachable !!"
	fi
	
	if [[ "$lxcdownload_con_check" == *"1 packets transmitted, 1 received"* ]]
	then
		$ECHO "LXC images server OK"
		con_check=$con_check+1
	else
		$ECHO "LXC images server unreachable !!"
	fi
		
	if [[ ! $con_check -eq 0 ]]
	then
		$ECHO "Connection to download server not possible, check that:\n 1- ALCASAR is connected to internet\n 2- mirrors.fedoraproject.com , download.fedoraproject.com , uk.images.linuxcontainers.org and pool.sks-keyservers.net are in the domain exception list "
		return
	fi
	TEST_CHECK=1
}

setup(){
	if [[ $EUID -ne 0 ]]
	then
		$ECHO "You have to be root to run this installer !"
		exit
	fi
	$ECHO "Welcome to PleiadeOS installer !"
	$ECHO "Before anything, be sure to plug the computer on the ALCASAR consulting network along with the PLEIADE server."
	
	$ECHO "Are you sure you want to procees (yes/no)"
	read answer
	if [ "$answer" != "yes" ]
	then
		exit
	fi

	testing
	$ECHO "Preliminary testing"
	if [[ $TEST_CHECK -eq 0 ]]
	then
		$ECHO "Something went wrong during testing phase"
		exit
	fi
	
	$ECHO "seting up the machine"
	prerequisites
	while [[ -z $ok ]]
	do
		$ECHO "Choose a mode (1 or 2):"
		$ECHO "1 - Contenerized user: the whole user space is isolated, providing even more security. However, display performance are degraded (video might be impossible). This is recommended for every nomad computers and computers that can be accessed by uncontrolled persons (ex: public access)."
	
		$ECHO "2 - Light mode: user space runs on the host system. Less secured, better performances. Suitable for desktop, or computers that stay on the same area"
	
		read mode
		
		$IP link add dev lxcbr0 type bridge
		main_if=$($IP route | $GREP -e "^default" | $AWK '{ print $5 }')
		$IP link set dev $main_if master lxcbr0
		kill $(pidof dhclient)
		$DHCLIENT lxcbr0
		
		if [[ $mode -eq 1 ]]
		then
			nomad_mode
			ok=1
		elif [[ $mode -eq 2 ]]
		then
			ok=1
		fi
		
		$ECHO "Configure launch at boot"
		
		$CAT << EOF > /etc/systemd/system/launch-pleiade.service
[Unit]
After=getty.target
Conflicts=getty@tty1.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/pleiade.sh
StandardInput=tty-force
StandardOutput=inherit
StandardError=inherit

[Install]
Alias=pleiade.service
WantedBy=default.target

EOF
		
		$SYSTEMCTL enable launch-pleiade.service
		
	done
}

setup
