#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey


# Still WIP, do not use it (but feel free to complete it ;) )

DNF=/bin/dnf
TAIL=/bin/tail
ECHO=/bin/echo
CUT=/bin/cut
CAT=/bin/cat
CP=/bin/cp
CHOWN=/bin/chown
TAR=/bin/tar
IP=/sbin/ip
DHCLIENT=/sbin/dhclient
GREP=/bin/grep
AWK=/bin/awk
PING=/bin/ping
SYSTEMCTL=/bin/systemctl
DF=/bin/df
TAIL=/bin/tail
TR=/bin/tr
OPENSSL=/bin/openssl


prerequisites(){
	$DNF install httpd openssh-server cockpit ntpd php php-fpm
	
	# We manipulate certificates, time is of the essence
	$SYSTEMCTL enable ntpd
	/sbin/ntpdate pool.ntp.org
	$SYSTEMCTL start ntpd
}


testing(){
	if [ $EUID -ne 0 ]
	then
		$echo "You have to be root to run this installer !"
		exit
	fi
	
	con_ok=$($PING -c1 google.com)
	if [[ "$con_ok" == *"1 packets transmitted, 1 received"* ]]
	then
		$ECHO "Connection is OK"
	else
		$ECHO "No internet connection !"
		exit
	fi
	
	var_space=$($DF -BG --output=avail /var | $TAIL -n1 | $TR -d [:space:]G)
	home_space=$($DF -BG --output=avail /home | $TAIL -n1 | $TR -d [:space:]G)
	
	if [ $var_space -lt 15 ]
	then
		$ECHO "free space on /var is $var_space Go, whereas it should at least be 15 Go"
		exit
	fi
	if [ $home_space -lt 50 ]
	then
		$ECHO "free space on /home is $home_space Go, whereas it should at least be 50 Go"
		exit
	fi
	
}

setup(){

	# TODO Generate config before copying it
	# Apache has the right to execute backend scripts (and does it as root so we use SUID bit)
	$CHOWN root:apache -R ./backend/root/bin
	$CHMOD -R 4710 ./backend/root/bin
	$CHMOD -R 700 ./backend/root/sbin
	$CHMOD -R 700 ./backend/root/root
	$CHMOD -R 600 ./backend/root/etc
	
	##### Certificate Authority #####	
	$OPENSSL req -new -x509 -extensions v3_ca -keyout key/ca.key -out crt/ca.crt -config ca.cnf
		
	$CP -R ./backend/root /

}
