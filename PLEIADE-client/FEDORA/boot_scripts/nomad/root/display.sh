#!/bin

CAT=/bin/cat
GREP=/bin/grep
AWK=/bin/awk
ECHO=/bin/echo
CUT=/bin/cut
FEH=/bin/feh

MODE=$($CAT /var/lib/lxc/pleiade-network/rootfs/root/config//root/user.cfg | $GREP "mode = " | $AWK -F' = ' '{ print $2 }')
COMMAND=$($CAT /var/lib/lxc/pleiade-network/rootfs/root/config/user.cfg | $GREP "command = " | $AWK -F' = ' '{ print $2 }')
CON_REQ=$($CAT /var/lib/lxc/pleiade-network/rootfs/root/config/user.cfg | $GREP "con_req = " | $AWK -F' = ' '{ print $2 }')


if [ "$MODE" == "kiosk" ]
then
	if [ "$CON_REQ" == "true" ]
	then
		/bin/sleep 10 && /bin/sshpass -p "kiosk" ssh -Y kiosk@10.0.3.21 /bin/connect_req.sh &
	fi
	/bin/sshpass -p "kiosk" ssh -Y kiosk@10.0.3.21 $COMMAND
elif [ "$MODE" == "user" ]
then
	# Draw pleiade background
	$FEH -F -Z /root/background &
	ENTRY=$(/bin/zenity --forms --title="Connexion" --add-entry="Login" --add-password="Password")

	case $? in

		0)
		
			USERNAME=$($ECHO $ENTRY | $CUT -d'|' -f1)
			PASSWORD=$($ECHO $ENTRY | $CUT -d'|' -f2)		
		
			/bin/sshpass -p "$PASSWORD" ssh -Y $USERNAME@10.0.3.21 $COMMAND
			;;
		1)
			/bin/echo "Aborted ..."
			;;

		-1)
			/bin/echo "Something went wrong !"
			;;

	esac

fi
