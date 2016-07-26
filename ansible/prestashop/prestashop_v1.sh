#!/bin/sh

# Deploy prestashop
# $1: Network ip (only class C)
# $2: Stack name (default:psstack)

cd $(dirname $0)

echo $1 | grep -qP "^\d+\.\d+\.\d+\.0$"

if [ "$?" = "0" ]
then
	net="$1"
else
	echo "Please provide a network ip ex: 10.0.1.0"
	exit 1
fi

if [ -z "$2" ]
then
	stackname="psstack"
else
	stackname="$2"
fi
ansible-playbook -vvvv prestashop_infra_v1.yaml -e network=$net -e stackname=$stackname
ansible-playbook -vvvv prestashop_app_v1.yaml -e stackname=$stackname
