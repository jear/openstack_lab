#!/bin/bash

# Deploy devstack on baremetal

labnum=$(hostname | sed 's/lab//i')

ctrl_ip=$(ip a | grep 10.3.222 | awk '{print $2}' | sed 's#/24##')
floating_ip_range="172.24.$labnum.0/24"
public_gw="172.24.$labnum.254"
floating_pool="start=172.24.$labnum.10,end=172.24.$labnum.100"
labenv="True"
vrgw="172.24.$labnum.10"

ansible-playbook -v -i inventory -e ctrl_ip=$ctrl_ip -e floating_ip_range=$floating_ip_range -e public_gw=$public_gw -e floating_pool=$floating_pool -e labenv=$labenv -e vrgw=$vrgw baremetal.yml
