#!/bin/bash
#clone the devstack repo 
#echo cloning devstack repo
#git clone https://git.openstack.org/openstack-dev/devstack
#devstack_dir is the directory which holds all of the files cloned form the devstack respository
echo cd into repo
cd /home/vagrant/devstack
devstack_dir=$(pwd)

#Devstack requires a local.conf file. There is no need to create our own
#In the devstack/samples/ folder there is one already written, however there are some 
#configurations which need to be re-configured (i.e USERRNAME, PASSWORD, HOST_IP_ADDRESS)
echo copying local.conf into devstack
sudo cp -r $devstack_dir/samples/local.conf $devstack_dir/local.conf

#Set Host IP addr to the private IP addr specified in the vagrantfile
#In future versions of this playbook this can be passsed in as an argument
echo configuring ip in local.conf
sudo sed -i -e 's:#HOST_IP=w.x.y.z:HOST_IP=10.1.0.10:' local.conf

#Start Devstack installation
echo runing stack.sh
./stack.sh