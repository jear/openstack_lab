#!/bin/bash

#################
# Prepare the lab
#################

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
	ssh-keygen -R $lab
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
pdsh -R ssh -w ^labhosts.txt "apt-get install -y git ansible vagrant virtualbox"
pdsh -R ssh -w ^labhosts.txt "vagrant box add ubuntu/trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
pdsh -R ssh -w ^labhosts.txt "git clone https://github.com/uggla/openstack_lab.git"
