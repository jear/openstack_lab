#!/bin/bash
nova boot --image "cirros-0.3.4-x86_64-uec" --flavor m1.tiny --key mykey cirros-script  # Create instance
pubip=$(openstack ip floating create -f json public | jq .ip | sed 's/"//g')            # Allocate an ip in pool
openstack ip floating add "$pubip" cirros-script                                        # Associate the ip to the instance
echo "VM should be accessible soon at $pubip"
