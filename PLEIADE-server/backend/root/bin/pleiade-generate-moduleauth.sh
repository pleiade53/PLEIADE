#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

ECHO=/bin/echo

if [[ $# -ne 1 ]]
then
	$ECHO "Wrong number of arguments. Usage:"
	$ECHO "$0 module_name"
	exit
fi
