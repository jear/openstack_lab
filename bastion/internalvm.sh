#!/bin/bash

openstack server create --flavor m1.tiny --image "cirros-0.3.4-x86_64-uec" --key-name bastionkey internalvm
vmip=$(openstack server show internalvm -f json | jq .addresses | awk '{print $1}' | sed 's/"private=//' | sed 's/,//')
sleep 30s
echo "VM ip $vmip"
