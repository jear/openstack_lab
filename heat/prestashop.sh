#!/bin/sh

# Prestashop stack

openstack stack create -t prestashop_v1.yaml --parameter "key_name=bastionkey;private_net_gateway=10.0.1.1;private_net_name=prestashop_net;private_net_cidr=10.0.1.0/24;private_net_pool_end=10.0.1.100;private_net_pool_start=10.0.1.10;image=Debian Jessie 64-bit;flavor=m1.small;public_net=public" prestashopstack
