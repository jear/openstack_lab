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
	doctl compute  droplet create devstack-$i --image $(doctl compute image list-distribution -o json | jq '.[] | select(.name=="14.04.5 x64") | .id') --size 8gb --region ams2 --ssh-keys 1997572
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

# Add ppa for latest Ansible
pdsh -R ssh -w ^labhosts.txt "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' >/etc/apt/sources.list.d/ansible.list"
pdsh -R ssh -w ^labhosts.txt "echo 'deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main ' >>/etc/apt/sources.list.d/ansible.list"
pdsh -R ssh -w ^labhosts.txt "gpg --ignore-time-conflict --no-options --no-default-keyring --secret-keyring /etc/apt/secring.gpg --trustdb-name /etc/apt/trustdb.gpg --keyring /etc/apt/trusted.gpg --primary-keyring /etc/apt/trusted.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367"

pdsh -R ssh -w ^labhosts.txt "apt-get update"
pdsh -R ssh -w ^labhosts.txt "apt-get install -y git ansible pdsh python-glanceclient python-novaclient python-openstackclient python-pip libpython2.7-dev xz-utils jq nmap python3-docopt libssl-dev libffi-dev tmux"
#pdsh -R ssh -w ^labhosts.txt "git clone https://github.com/uggla/openstack_lab.git"
pdsh -R ssh -w ^labhosts.txt "pip install -U pip"
pdsh -R ssh -w ^labhosts.txt "pip install -U setuptools"
#pdsh -R ssh -w ^labhosts.txt "pip install -U urllib3[secure]"
#pdsh -R ssh -w ^labhosts.txt "pip install -U pbr"
#pdsh -R ssh -w ^labhosts.txt "pip install -U os_client_config"
#pdsh -R ssh -w ^labhosts.txt "pip install -U shade"
pdsh -R ssh -w ^labhosts.txt 'sed -ri "\$a export EDITOR=vim" .bashrc'  # Use vim instead of nano
pdsh -R ssh -w ^labhosts.txt "sed -ri '/bash_completion/,/fi/ s/^#//' .bashrc" # Add bash completion
#pdsh -R ssh -w ^labhosts.txt 'cat /dev/zero | ssh-keygen -q -N ""; ls -al ~/.ssh/id_rsa'
#pdsh -R ssh -w ^labhosts.txt 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
#pdsh -R ssh -w ^labhosts.txt "ssh-keyscan -t rsa localhost | cat >> ~/.ssh/known_hosts"

pdsh -R ssh -w ^labhosts.txt "useradd -m -s /bin/bash stack" 
pdsh -R ssh -w ^labhosts.txt "usermod -G sudo stack" 
pdsh -R ssh -w ^labhosts.txt "perl -i -pe 's/^%sudo.+/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers"
pdsh -R ssh -w ^labhosts.txt 'su - stack -c "git clone https://git.openstack.org/openstack-dev/devstack && cd devstack && git checkout stable/mitaka"' 
