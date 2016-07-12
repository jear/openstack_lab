#!/bin/bash

#################
# Prepare the lab
#################

function usage {

echo "Usage: $prog baremetal|virtual"
echo ""
echo "baremetal	Openstack controller will be hosted on baremetal"
echo "virtual		Openstack controller will be hosted on a vagrant(virtualbox) VM"
exit 0
}

arg1=$(echo "$1" | tr [:upper:] [:lower:])
prog=$(basename $0)

case "$1" in
	"baremetal" )
	platform=$1
	;;

	"virtual" )
	platform=$1
	;;

	* )
	usage
	;;
esac

# Checking tool deps
for tool in ssh sshpass pdsh
do
	echo "Checking $tool"
	which $tool || exit 1
done

# Pushing keys to labhosts
echo "Enter ssh pwd:"
read -s sshpwd

for lab in $(cat labhosts.txt)
do
	ssh-keygen -R $(echo $lab | sed -r 's/.+@//g')
	ssh-keyscan -t rsa $(echo $lab | sed -r 's/.+@//g') | cat >> ~/.ssh/known_hosts
	echo "$sshpwd" | sshpass ssh-copy-id $lab
done

pdsh -R ssh -w ^labhosts.txt uname -a
labcount=$(pdsh -R ssh -w ^labhosts.txt uname -a | wc -l)
labcountfile=$(cat labhosts.txt | wc -l)

if [ "$labcount" != "$labcountfile" ]
then
	echo "Host preparation failed"
	exit 1
fi

# Get the lab bits
if [ "$platform" == "virtual" ]
then
	pdsh -R ssh -w ^labhosts.txt "apt-get install -y vagrant virtualbox"
	pdsh -R ssh -w ^labhosts.txt "ls .vagrant.d/boxes/ubuntu/0/trusty64" || \
	pdsh -R ssh -w ^labhosts.txt "vagrant box add ubuntu/trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
fi

# Add ppa for latest Ansible
pdsh -R ssh -w ^labhosts.txt "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' >/etc/apt/sources.list.d/ansible.list"
pdsh -R ssh -w ^labhosts.txt "echo 'deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main ' >>/etc/apt/sources.list.d/ansible.list"
pdsh -R ssh -w ^labhosts.txt "gpg --ignore-time-conflict --no-options --no-default-keyring --secret-keyring /etc/apt/secring.gpg --trustdb-name /etc/apt/trustdb.gpg --keyring /etc/apt/trusted.gpg --primary-keyring /etc/apt/trusted.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367"

pdsh -R ssh -w ^labhosts.txt "apt-get update"
pdsh -R ssh -w ^labhosts.txt "apt-get install -y git ansible pdsh python-glanceclient python-novaclient python-openstackclient python-pip libpython2.7-dev xz-utils jq"
pdsh -R ssh -w ^labhosts.txt "git clone https://github.com/uggla/openstack_lab.git"
pdsh -R ssh -w ^labhosts.txt "pip install -U pip"
pdsh -R ssh -w ^labhosts.txt "pip install -U pbr"
pdsh -R ssh -w ^labhosts.txt "pip install -U shade"
pdsh -R ssh -w ^labhosts.txt "pip install -U os_client_config"
pdsh -R ssh -w ^labhosts.txt 'sed -ri "\$a export EDITOR=vim" .bashrc'  # Use vim instead of nano
pdsh -R ssh -w ^labhosts.txt "sed -ri '/bash_completion/,/fi/ s/^#//' .bashrc" # Add bash completion
pdsh -R ssh -w ^labhosts.txt 'cat /dev/zero | ssh-keygen -q -N ""; ls -al ~/.ssh/id_rsa'
pdsh -R ssh -w ^labhosts.txt 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
pdsh -R ssh -w ^labhosts.txt "ssh-keyscan -t rsa localhost | cat >> ~/.ssh/known_hosts"

echo ""
echo "******************************************"
echo "Your host should be ready to be deployed !"
echo "******************************************"
echo "Run to continue:"
if [ "$platform" == "virtual" ]
then
	echo "1) pdsh -R ssh -w ^labhosts.txt 'cd openstack_lab/devstack/virtual && vagrant up'"
	echo "2) pdsh -R ssh -w ^labhosts.txt 'cd openstack_lab/devstack/common && ./post_config.sh'"
else
	echo "1) pdsh -R ssh -w ^labhosts.txt 'cd openstack_lab/devstack/baremetal && ./deploy.sh'"
	echo "2) pdsh -R ssh -w ^labhosts.txt 'cd openstack_lab/devstack/common && ./post_config.sh'"
fi

