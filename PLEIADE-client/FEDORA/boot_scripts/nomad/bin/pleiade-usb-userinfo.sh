#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

ZENITY=/bin/zenity
CAT=/bin/cat
GREP=/bin/grep

get_details()
{
	/bin/python ./get-usb-report.py $1 -d
}

get_summary()
{
	/bin/python ./get-usb-report.py $1 -s
}


if [ ! -z $1 ] && [ ! -z $2 ]
then
	
	if [ "$1" == "started" ]
	then
		$ZENITY --info --text "Analyse commencée pour $2"
	elif [ "$1" == "clean" ]
	then
		$ZENITY --info --ellipsize --text="$(get_summary $2)"
	elif [ "$1" == "virus" ]
	then
		$ZENITY --warning --text="$(get_summary $2)\n $(get_details $2)"
	else
		$ZENITY --error --text="Erreur lors de l'analyse de $2"
	fi
fi
