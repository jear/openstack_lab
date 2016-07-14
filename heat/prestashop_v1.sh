#!/bin/sh

# Prestashop stack
#
# $1: Network ip (only class C)
# $2: Stack name (default:prestashopstack)

cd $(dirname $0)

echo $1 | grep -qP "^\d+\.\d+\.\d+\.0$"

if [ "$?" = "0" ]
then
	net="$1/24"
	netgw=$(echo "$1" | sed 's/0$/1/')
else
	echo "Please provide a network ip ex: 10.0.1.0"
	exit 1
fi

if [ -z "$2" ]
then
	stackname="prestashopstack"
else
	stackname="$2"
fi

openstack stack create  --wait -t prestashop_v1.yaml -e prestashop_v1_param.yaml --parameter \
"srvweb_name=$stackname-web;\
srvdb_name=$stackname-db;\
private_net_name=$stackname;\
private_net_cidr=$net;\
private_net_gateway=$netgw"\
 $stackname

# Get internal ip to register ssh host keys:
webip=$(openstack stack output show prestashopstack server1_private_ip -f json | jq ."output_value" | sed 's/"//g')
dbip=$(openstack stack output show prestashopstack server2_private_ip -f json | jq ."output_value" | sed 's/"//g')

# Remove previous keys if any
ssh-keygen -R "$webip"
ssh-keygen -R "$dbip"

# Register ssh host keys
ssh -F ../ansible/ssh_config debian@bastion "ssh-keyscan -v -t rsa $webip" >>~/.ssh/known_hosts
ssh -F ../ansible/ssh_config debian@bastion "ssh-keyscan -v -t rsa $dbip" >>~/.ssh/known_hosts
