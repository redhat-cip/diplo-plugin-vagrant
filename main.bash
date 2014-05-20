#!/bin/bash

function bootstrap() {
	cd $DIR/workspaces/$1
	source vagrant.cfg
	for i in $BOXES
	do
		title=`echo $i|awk -F';' '{print $1}'`
		url=`echo $i|awk -F';' '{print $2}'`
		BOX=`vagrant box list | awk -F' ' '{print $1}' | grep "^$title$" | wc -l`
		if [ $BOX -eq 0 ]
		then
			if [ "`vagrant -v | awk -F' ' '{print $2}' | awk -F'.' '{print $1"."$2}'`" == "1.5" ]
			then
				vagrant box add --name $title $url
			else
				vagrant box add $title $url
			fi
		else
			echo "Vagrant Box $title already present"
		fi
	done
}

function up() {
	cd $DIR/workspaces/$1
	source vagrant.cfg
	for i in $ORDER
	do
		vagrant up $i
	done
}
