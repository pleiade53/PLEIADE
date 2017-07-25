#!/bin/bash

for user in $($CAT /var/www/html/pcc/.htpasswd)
do
	$ECHO "$user" | $CUT -d':' -f1
done
