#!/bin/bash

openstack server create --flavor m1.tiny --image "cirros-0.3.4-x86_64-uec" --key-name bastionkey internalvm
vmip=""

while [ -z "$vmip" ]
do
	vmip=$(openstack server show internalvm -f json | jq .addresses | perl -pe 's#.*\s(\d+\.\d+\.\d+\.\d+).*#\1#g')
	sleep 5s
done

echo "VM ip $vmip"
