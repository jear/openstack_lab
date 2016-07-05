# -*- mode: ruby -*-
# vi: set ft=ruby :



Vagrant.configure("2") do |config|

	# Check environment variable to difine a particular deployment
	labenv=ENV[LABENV]

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
	#config.vm.provision :shell, :inline => "sudo ip r change default via 10.3.222.1"

    #config.vm.provision :ansible do |ansible|
    #    ansible.host_key_checking = false
    #    ansible.playbook = "devstack.yml"
    #    ansible.verbose = "v"
    #end
    #config.vm.provision :shell, :inline => "cd devstack; sudo -u vagrant env HOME=/home/vagrant ./stack.sh"
    #config.vm.provision :shell, :inline => "ovs-vsctl add-port br-ex eth2"
    #config.vm.provision :shell, :inline => "virsh net-destroy default"


end
