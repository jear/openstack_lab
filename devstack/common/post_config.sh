#!/bin/bash

# Post configuration of our lab to make it more convenient for students
cd $(dirname $0)
currentdir=$(pwd)
ps -ef | grep [V]BoxHeadless && virtual=yes

if [ "$virtual" == "yes" ]
then
	cd ../virtual
	pwd
	source ./admin.openrc
	cd $currentdir
else
	cd ../baremetal
	source ./admin.openrc
	cd $currentdir
fi

# Load debian image
cd ../images
if [ ! -f debian-8.5.0-openstack-amd64.qcow2 ]
then
	wget http://cdimage.debian.org/cdimage/openstack/8.5.0/debian-8.5.0-openstack-amd64.qcow2
	glance image-create \
		--name="Debian Jessie 64-bit" \
		--disk-format=qcow2 --container-format=bare \
		--property architecture=x86_64 \
		--progress \
		--file debian-8.5.0-openstack-amd64.qcow2
fi

# Load Centos 6 image
cd ../images
if [ ! -f CentOS-6-x86_64-GenericCloud.qcow2 ]
then
	wget http://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2.xz
	xz -dv CentOS-6-x86_64-GenericCloud.qcow2.xz
	glance image-create \
		--name="CentOS 6" \
		--disk-format=qcow2 --container-format=bare \
		--property architecture=x86_64 \
		--progress \
		--file CentOS-6-x86_64-GenericCloud.qcow2
fi

# Remove all flavor
openstack flavor delete m1.tiny
openstack flavor delete m1.small
openstack flavor delete m1.medium
openstack flavor delete m1.large
openstack flavor delete m1.xlarge
sleep 10s

# Create flavor
nova flavor-create m1.tiny 1 512 1 1
nova flavor-create m1.small 2 512 5 1
nova flavor-create m1.medium 3 1024 10 1

# Allow ssh
export OS_USERNAME=demo
openstack security group rule create --prefix 0.0.0.0/0 --proto tcp --src-ip 0.0.0.0/0 --dst-port 22 default

# Allow icmp
openstack security group rule create --prefix 0.0.0.0/0 --proto icmp --src-ip 0.0.0.0/0 --dst-port -1 default

