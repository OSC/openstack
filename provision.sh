#!/bin/bash

#change into accr 
echo "Starting OpenStack All-In-One Provision Script"
cd /home/vagrant/devstack
source accrc/admin/admin

 
#download ubuntu  image
echo "Downloading Ubuntu Image"
mkdir -p data/images
cd data/images
wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img


#upload image to glance 
echo Uploading Image to Glance 
openstack image create --public --min-disk 1 --container-format bare \
--disk-format qcow2 --property architecture=x86_64 \
--property hw_disk_bus=virtio --property hw_vif_model=virtio \
--file xenial-server-cloudimg-amd64-disk1.img \
"xenial x86_64"

#log the creation of the image 
openstack image list 


#create osc domain 
echo creating domain
# cd /home/vagrant/devstack
# openstack domain create devstack.osc

#Create/add project to domain
echo Create/add project to domain
openstack project create --domain default \
--description 'POC cloud infrastructure for interacting with Open On Demand' ohio_super_computing

#create user and add to  project 
echo Create/add user to project
openstack user create --domain default \
 --project-domain default --project ohio_super_computing \
 --password-prompt satoshi

touch /home/vagrant/devstack/accrc/admin/sat.rc
cat > /home/vagrant/devstack/accrc/admin/sat.rc<< EOF
# OpenStack USER ID = d0172a53f81d4e00a40437a820f2fa4c
export OS_USERNAME="satoshi"
export OS_PROJECT_NAME="ohio_super_computing"
export OS_AUTH_URL="http://10.1.0.10/identity"
export OS_CACERT=""
export NOVA_CERT="/home/vagrant/devstack/accrc/cacert.pem"
export OS_PASSWORD="password"
#export OS_USER_DOMAIN_ID=default
unset OS_USER_DOMAIN_NAME
#export OS_PROJECT_DOMAIN_ID=default
unset OS_PROJECT_DOMAIN_NAME
EOF

#create private network
echo creating private/internal network for project  
openstack network create Finney 

 #create private subnet 
openstack subnet create HalNet --allocation-pool \
start=10.0.0.10,end=10.0.0.99 --subnet-range 10.0.0.0/24 \
--gateway 10.0.0.1 --dns-nameserver 8.8.8.8 --network Finney

#create router 
#connect it to external netwrok 
#add private subnet to the router
echo creating router for project 
openstack router create Router1
openstack router set Router1 --external-gateway public 
openstack router add subnet Router1 HalNet

#add a floating ip to the ip pool, our instance will use this ip address to be accesed from the public network 
echo creating floating ip
openstack floating ip create public 

#create ssh keypair & security group , for accessing instances via ssh
echo creating new keypair and security group
openstack keypair create NewKeypair > ~/.ssh/newkeypair.pem
chmod 600 ~/.ssh/newkeypair.pem
openstack security group create --description 'Allow SSH' Allow_SSH
openstack security group rule create --proto tcp --dst-port 22 Allow_SSH
openstack security group rule create --proto icmp --ingress Allow_SSH
openstack security group rule create --proto icmp --egress Allow_SSH

#get the network id  of the "public" network
netID=$(openstack network list | grep 'Finney' | cut -d \| -f 2 |  awk '{$2=$2}1')

#create a new flavor for the instance
#When using the flavors opensatck ships with the server never becomes active
echo creating new flavor 
openstack flavor create --ram 2048  --disk 0  --vcpus 1 --rxtx 1 --public m2.small

#create instance
echo creating server
openstack server create --availability-zone nova \
--image 'xenial x86_64' --flavor m2.small \
--key-name NewKeypair --security-group \
Allow_SSH  --nic net-id=$netID Ubuntu 

#get floating ip 
floatingIP=$(openstack floating ip list | grep 'None' | cut -d \| -f 3 |  awk '{$2=$2}1')

#attach floating ip to the instance 
echo add floating ip to server 
openstack server add floating ip Ubuntu $floatingIP










