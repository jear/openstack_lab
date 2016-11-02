#!/bin/bash

# Cloud Native Application stack
#
# $1: Network ip (only class C)
# $2: Stack name (default: mstack)

cd $(dirname $0)

echo $1 | grep -qP "^\d+\.\d+\.\d+\.0$"

if [ "$?" = "0" ]
then
	net="$1/24"
	netgw=$(echo "$1" | sed 's/0$/1/')
	thirddigit=$(echo $1 | awk -F'.' '{print $3}')
	let "thirddigit=$thirddigit + 1"
	net2="$(echo $1 | awk -F'.' '{printf("%s.%s",$1,$2)}').$thirddigit.0/24"
	net2gw=$(echo "$net2" | sed 's/0\/24$/1/')
else
	echo "Please provide a network ip ex: 10.0.1.0"
	exit 1
fi

if [ -z "$2" ]
then
	stackname="mstack"
else
	stackname="$2"
fi

# Get default security group id
default_scid=$(openstack security group show default -f json | jq .id | sed 's/"//g')
consul_scid=$(openstack security group show consulstack -f json | jq .id | sed 's/"//g')

# Create stack volume if it does not exist, this is for redis
openstack volume list | grep -q "$stackname"
if [ $? != 0 ]
then
	openstack volume create "$stackname" --size 5
	sleep 30s
fi

# Get volume id
volid=$(openstack volume show "$stackname" -f json | jq ."id" | sed 's/"//g')

# Create stack
openstack stack create  --wait -t cna.yaml -e cna_param.yaml --parameter \
"srvweb_name=$stackname-web;\
srvha_name=$stackname-ha;\
srvi_name=$stackname-i;\
srvs_name=$stackname-s;\
srvb_name=$stackname-b;\
srvp_name=$stackname-p;\
srvw1_name=$stackname-w1;\
srvw2_name=$stackname-w2;\
srvrd_name=$stackname-rd;\
default_scid=$default_scid;\
consul_scid=$consul_scid;\
private_net_name=$stackname;\
private_net2_name=$stackname-2;\
private_net_cidr=$net;\
private_net_gateway=$netgw;\
private_net2_cidr=$net2;\
private_net2_gateway=$net2gw;\
diskname=$volid"\
 $stackname
