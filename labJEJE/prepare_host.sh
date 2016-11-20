#!/bin/bash

##############################
# Create Digital Ocean droplet
##############################

function usage {

echo "Usage: $prog password"
echo ""
echo "password	Instance and openstack password"
exit 1
}

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

if [ -z "$1" ]
then
	usage
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
pdsh -R ssh -w ^labhosts.txt 'su - stack -c "cd devstack && wget https://raw.githubusercontent.com/uggla/openstack_lab/cloudnative/labJEJE/local.conf"' 
pdsh -R ssh -w ^labhosts.txt $(cat << EOF
su - stack -c "cd devstack && perl -i -pe s/secret/$1/ local.conf"
EOF)
pdsh -R ssh -w ^labhosts.txt 'su - stack -c "cd devstack && ./stack.sh"' 
pdsh -R ssh -w ^labhosts.txt 'su - stack -c "cd devstack && wget http://cdimage.debian.org/cdimage/openstack/current/debian-8.6.2-openstack-amd64.qcow2"' 
pdsh -R ssh -w ^labhosts.txt "echo stack:$1 | chpasswd"
