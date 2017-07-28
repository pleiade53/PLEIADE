#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

SRC=FEDORA
DST="."

if [[ $# == 2 ]]
then
	SRC=$2
fi

if [[ $# -gt 0 ]]
then
	DST=$1
	mkdir -p DST
fi

if [[ $# -gt 2 ]]
then
	echo "usage: $0 (dst_dir) (src_dir)"
	exit
fi

mkdir pleiade-installer

compr_str="pleiade-installer/install-pleiade.sh pleiade-installer/boot_scripts"
cp $SRC/install-pleiade.sh pleiade-installer
cp -R $SRC/boot_scripts pleiade-installer

for container in $(ls "$SRC"/ | grep "pleiade-")
do
	cp -r "$SRC/$container" ./
	tar -czf pleiade-installer/"$container".tar.gz "$container"
	compr_str="$compr_str pleiade-installer/$container".tar.gz
	rm -Rf $container
done

tar -czf pleiade-installer.tar.gz $compr_str
mv pleiade-installer.tar.gz $DST

rm -Rf pleiade-installer
