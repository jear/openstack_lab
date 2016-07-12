#!/bin/bash
nova boot --image "cirros-0.3.4-x86_64-uec" --flavor m1.tiny --key mykey cirros-script
pubip=$(openstack ip floating create -f json public | jq .ip)
openstack ip floating add "$pubip" cirros-script
