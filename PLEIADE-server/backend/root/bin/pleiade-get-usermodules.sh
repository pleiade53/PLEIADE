#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

ECHO=/bin/echo
CAT=/bin/cat
AWK=/bin/awk

IFS=$'\n'

if [[ $# -ne 1 ]]
then
	$ECHO "Illegal number of arguments"
	$ECHO "Usage:"
	$ECHO "$0 username"
	exit
fi

FOLDER=/var/www/html/
# retrieve links accessible to everyone
LINKS=/var/www/html/pvd/general_links

for module in $($CAT $LINKS)
do
	# declare links as follow: 
	# Google|www.google.com
	# link2|www.url.to.link2
	# ...
	icon=/pvd/resources/browser.png	
	name=$($ECHO "$module" | $AWK -F'|' '{print $1}')
	link=$($ECHO "$module" | $AWK -F'|' '{print $2}')
	info=$link
	
	$ECHO "$name ; $icon ; $info ; $link"
done
for module in $($CAT "$FOLDER"/pvd/"$1"/modules_list)
do
	icon=/"$module"/icon.png
	info=$($CAT "$FOLDER"/"$module"/info.txt)
	name=$module
	link="/$name"
	
	$ECHO "$name ; $icon ; $info ; $link"
done
