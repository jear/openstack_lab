# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'socket'

Vagrant.configure("2") do |config|

	# Check environment variable to define a particular deployment
	labhosts = Hash["lab1" => "10.3.222.61",
		            "lab2" => "10.3.222.62",
		            "lab3" => "10.3.222.63",
		            "lab4" => "10.3.222.64",
		            "lab5" => "10.3.222.65",
		            "lab6" => "10.3.222.66",
		            "lab7" => "10.3.222.67",
		            "lab8" => "10.3.222.68",
		            "lab9" => "10.3.222.69",
		            "lab10" => "10.3.222.70"]

	labenv=ENV["LABENV"]
	hostname = Socket.gethostbyname(Socket.gethostname).first.split(".").first

	memory=6144
	cpu=2

	if labenv == "LAB"
		memory=12288
		cpu=4
	end

    config.vm.box = "ubuntu/trusty64"
    config.ssh.forward_agent = true
    # eth1, this will be the endpoint
		config.vm.network :private_network, ip: "192.168.27.100"

	if labenv == "LAB"
		config.vm.network :public_network, ip: labhosts[hostname] 
	else
		config.vm.network :private_network, ip: "192.168.27.100"
	end

    # eth2, this will be the OpenStack "public" network
    # ip and subnet mask should match floating_ip_range var in devstack.yml
    config.vm.network :private_network, ip: "172.24.4.225", :netmask => "255.255.255.0", :auto_config => false

	# Set VM provider
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", memory]
        vb.customize ["modifyvm", :id, "--cpus", cpu]
        # eth2 must be in promiscuous mode for floating IPs to be accessible
        vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end

    # default router
	if labenv == "LAB"
		config.vm.provision :shell, :inline => "sudo ip r change default via 10.3.222.1"
	end

    #config.vm.provision :ansible do |ansible|
    #    ansible.host_key_checking = false
    #    ansible.playbook = "devstack.yml"
    #    ansible.verbose = "v"
    #end
    #config.vm.provision :shell, :inline => "cd devstack; sudo -u vagrant env HOME=/home/vagrant ./stack.sh"
    #config.vm.provision :shell, :inline => "ovs-vsctl add-port br-ex eth2"
    #config.vm.provision :shell, :inline => "virsh net-destroy default"


end
