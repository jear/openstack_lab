#!/bin/bash

# Post configuration of our lab to make it more convenient for students

source admin.openrc

glance image-create \
    --name="Debian Jessie 64-bit" \
    --disk-format=qcow2 --container-format=bare \
    --property architecture=x86_64 \
    --progress \
    --file images/debian-8.0.0-openstack-amd64.qcow2

