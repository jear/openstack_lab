#!/bin/bash

# Post configuration of our lab to make it more convenient for students

source labadmin.openrc

# Load debian image
glance image-create \
    --name="Debian Jessie 64-bit" \
    --disk-format=qcow2 --container-format=bare \
    --property architecture=x86_64 \
    --progress \
    --file images/debian-8.5.0-openstack-amd64.qcow2

# Remove all flavor
openstack flavor delete m1.tiny
openstack flavor delete m1.small
openstack flavor delete m1.medium
openstack flavor delete m1.large
openstack flavor delete m1.xlarge

# Create flavor
nova flavor-create m1.tiny 1 512 1 1
nova flavor-create m1.small 2 512 5 1
nova flavor-create m1.medium 3 1024 10 1

# Allow ssh
openstack security group rule create --prefix 0.0.0.0/0 --proto tcp --src-ip 0.0.0.0/0 --dst-port 22 default

# Allow icmp
openstack security group rule create --prefix 0.0.0.0/0 --proto icmp --src-ip 0.0.0.0/0 --dst-port -1 default

