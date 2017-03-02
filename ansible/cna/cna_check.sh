#!/bin/sh

# Deploy cna
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

if [ ${#stackname} -gt 10 ]
then
	echo "Stackname should not exceed 10 chars"
	exit 1
fi


invok=$(basename $0)
fkey=""
docheck=""

if [ "$invok" = "cna_sup.sh" ]
then
	ansible-playbook -vvvv cna_infra_sup.yaml -e network=$net -e stackname=$stackname
        if [ $? -ne 0 ]
	then
		echo "Scale up failed"
		exit 1
	fi
fkey="-e force_host_keys=yes"
fi

if [ "$invok" = "cna_sdn.sh" ]
then
	ansible-playbook -vvvv cna_infra_sdn.yaml -e network=$net -e stackname=$stackname
        if [ $? -ne 0 ]
	then
		echo "Scale down failed"
		exit 1
	fi
fi

if [ "$invok" = "cna_check.sh" ]
then
        # Checking the stack broke the asg. To fix the stack needs to be updated.
        # So avoid the check most of the time unless check is really required.
	docheck="-e docheck=true"
fi

ansible-playbook -vvvv cna_infra.yaml -e network=$net -e stackname=$stackname $fkey $docheck
ansible-playbook -vvvv cna_app.yaml -e stackname=$stackname
