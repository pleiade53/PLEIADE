#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

GREP=/bin/grep
AWK=/bin/awk
CAT=/bin/cat
TAIL=/bin/tail
ECHO=/bin/echo

MODE="kiosk"
COMMAND="firefox -private 9.0.0.1" 
CON_REQ="true"

for arg in $@
do	
	if [[ "$arg" == "--mode="* ]]
	then
		MODE=$($ECHO $arg | $AWK -F 'mode=' '{print $2}')
		if [ "$MODE" == "user" ]
		then
			COMMAND="startlxde"
		fi
	elif [[ "$arg" == "--con_req="* ]]
	then
		CON_REQ=$($ECHO $arg | $AWK -F 'con_req=' '{print $2}')
	elif [[ "$arg" == "--kiosk_url="* ]]
	then
		MODE="kiosk"
		COMMAND="/bin/firefox -private $($ECHO $arg | $AWK -F 'kiosk_url=' '{print $2}')"
	fi
done

PLEIADE_LOCAL=$($GREP "PleiadeLocalAddress = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')
ALCASAR_GATEWAY=$($GREP "AlcasarGateway = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')
PLEIADE_PUBLIC=$($GREP "PublicAddress = " /etc/pleiade.cfg | $AWK -F' = ' '{print $2}')

$CAT << EOF
pleiade_server_public = $PLEIADE_PUBLIC
pleiade_server_local = $PLEIADE_LOCAL
alcasar_server = $ALCASAR_GATEWAY

mode = $MODE
command = $COMMAND
con_req = $CON_REQ
EOF

