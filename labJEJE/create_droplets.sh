#!/bin/bash

##############################
# Create Digital Ocean droplet
##############################

function usage {

echo "Usage: $prog nb_instance"
echo ""
echo "nb_instance	Number of instances required"
exit 1
}

arg1=$(echo "$1" | tr [:upper:] [:lower:])
prog=$(basename $0)

#case "$1" in
#	"baremetal" )
#	platform=$1
#	;;
#
#	"virtual" )
#	platform=$1
#	;;
#
#	* )
#	usage
#	;;
#esac

echo "$1" | grep -Pq "\d+"
if [ "$?" != 0 ]
then
	usage
fi

# Checking tool deps
for tool in ssh sshpass pdsh doctl jq
do
	echo "Checking $tool"
	which $tool || exit 1
done

# Following lines are not needed. Keys are pushed by DO. The key must be known by DO.
# Pushing keys to labhosts
#echo "Enter ssh pwd:"
#read -s sshpwd

# Create the required instances
for i in $(seq $arg1)
do
	doctl compute  droplet create devstack-$i --image $(doctl compute image list-distribution -o json | jq '.[] | select(.name=="14.04.5 x64") | .id') --size 16gb --region ams2 --ssh-keys 1997572
done

# Wait instance to be ready
for i in $(seq $arg1)
do
	instanceok="false"
	while [ "$instanceok" != "true" ]
	do
		doctl compute  droplet list | grep "devstack-$i" | grep "active"
		if [ "$?" != 0 ]
		then
			sleep 10s
		else
			instanceok="true"
		fi
	done
done

# Wait instances to be completely ready
sleep 20s

# Create labhost.txt file
> labhosts.txt
for i in $(doctl compute droplet list | grep devstack | awk '{ print $3 }')
do
	echo "root@$i" >> labhosts.txt
done

for lab in $(cat labhosts.txt)
do
	#ssh-keygen -R $(echo $lab | sed -r 's/.+@//g')
	ssh-keyscan -t rsa $(echo $lab | sed -r 's/.+@//g') | cat >> ~/.ssh/known_hosts
	#echo "$sshpwd" | sshpass ssh-copy-id $lab
done

pdsh -R ssh -w ^labhosts.txt uname -a
labcount=$(pdsh -R ssh -w ^labhosts.txt uname -a | wc -l)
labcountfile=$(cat labhosts.txt | wc -l)

if [ "$labcount" != "$labcountfile" ]
then
	echo "Host preparation failed"
	exit 1
fi

echo "Digital Ocean droplets ready."
exit 0
