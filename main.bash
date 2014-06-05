#!/bin/bash

function status() {
	VDIR=`which vagrant`
	RETCODE=$?
	if [ $RETCODE -ne 0 ]
	then
		error "Hmmm ... maybe you have to install vagrant to use this plugin : http://www.vagrantup.com/"
		error "To re-check after installation use this commande : diplo vagrant status"
		exit 1
	fi
	debug "Vagrant found at $VDIR"
	VVER=`vagrant -v | awk -F' ' '{print $2}' | awk -F'.' '{print $1"."$2}'`
	if [ $VVER != "1.5" ] && [ $VVER != "1.6" ]
	then
		error "You need to update Vagrant, Diplo support version 1.5+"
		exit 1
	fi
	VPLUG=`vagrant plugin list`
	if [ `echo "$VPLUG" | grep vagrant-aws | wc -l` -ne 1 ]
	then
		error "Missing vagrant-aws plugin just install it : vagrant plugin install vagrant-aws"
		exit 1
	fi
	if [ `echo "$VPLUG" | grep vagrant-openstack-plugin | wc -l` -ne 1 ]
        then
                error "Missing vagrant-openstack-plugin plugin just install it : vagrant plugin install vagrant-openstack-plugin"
                exit 1
        fi
		
}

function bootstrap() {
	cd $DIR/workspaces/$1
	source conf/vagrant.cfg
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
	source conf/vagrant.cfg
	for i in $ORDER
	do
		vagrant up $i --provider=$PROVIDER
	done
}
