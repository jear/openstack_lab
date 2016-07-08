#!/bin/bash

# Deploy devstack on baremetal

labnum=$(hostname | sed 's/lab//i')


floating_ip_range="172.24.$labnum.0/24"
public_gw="172.24.$labnum.254"
floating_pool="start=172.24.$labnum.10,end=172.24.$labnum.100"
labenv="True"
vrgw="172.24.$labnum.10"

ssh-keyscan -t rsa localhost | cat >> ~/.ssh/known_hosts

ansible-playbook -i inventory -e floating_ip_range=$floating_ip_range -e public_gw=$public_gw -e floating_pool=$floating_pool -e labenv=$labenv -e vrgw=$vrgw baremetal.yml
