# Work In Progress !

# Openstack and cloud native application

This lab is in 2 parts:
  1. The infrastructure driven API.
  2. Create your cloud native application.

* The goal of the first part is automate infrastructure deployments and changes (Infrastructure as code concept). Within this part we are using Openstack as our Infrastructure As A Service platform but this is an implementation choice. The same principles can be implemented on top of another platform like Eucalyptus, Cloudstack, Amazon AWS, Azure.

* The goal of the second part is to create a cloud native application and to explain the concepts around that. All of this is completely platform agnostic. Of course in our case, we will do it on top of Openstack.

Both parts are independent and can be followed in any order. However, people coming from operational (ops) world will be probably more familiar with the first part. Contrary to people coming from the development (dev) world that should be more familiar with the second one.

Expected duration for each part is : 240 minutes.


## Lab Writer and Trainer
  - Bruno.Cornec@hpe.com
  - Rene.Ribaud@hpe.com

<!--- [comment]: # Table of Content to be added --->

## Prerequisites

In order to follow this lab, you need to :

Part one :
* Be familiar with Linux.
* Have knowledge with IAAS and Openstack (follow our colleagues Openstack training).
* Have a few network knowledge.

Part two :
* Be familiar with Linux.
* Have knowledge with IAAS and Openstack.
* Some knowledge in the development world.

## Objectives of Lab
At the end of the Lab part one, students should be able to understand automation concept and be able to do their own automation scenario.

At the end of the Lab part two, students should be able to understand cloud native application concepts and be able to explain/apply some of them in their day to day job.

This Lab is intended to be trial and error so that during the session students should understand really what is behind the tools and concept, instead of blindly following instructions, which never teach people anything IMHO. You've been warned ;-)


## Reference documents

TBD

Estimated time for the lab is placed in front of each part.




# The infrastructure driven API (part 1)


## 2 words about Openstack

Openstack is a cloud solution to implement Infrastructure As A Service solution.

Key strengths :

* Drivers allow abstraction of the underlying physical infrastructure. Example, the way to create a persistent volume will be the same whatever the physical storage used (HPE, EMC).

* Standard defined API will allow automation whatever the tool/languages used.

* Opensource, all piece of code can be used, seen, modified.

## Lab environment description

Openstack suppliers (HPE, Redhat, Mirantis etc...) will bundle Openstack upstream projects and create an Openstack distribution.

The one used in our lab is the devstack, this is "distribution" intended to develop Openstack.

Here is the lab environment:
(do not forget to mention DNS)


## Stop talking, get our hands dirty !

### Minimal checks of the platform

1. Connect to the horizon console.
2. Deploy a "myinstance" cirros tiny instance using your lab station ssh key.
3. Create a floating ip associated to your instance.
4. Connect  to your instance using ssh and keys (login: cirros).
![cirros__login](img/cirros_login.png)
5. Check if you can ping an internet ip address (8.8.8.8), try with a fqdn (google.fr). Something should be wrong here, try to permanently fix that issue, and follow next steps to validate it. (hint update nw settings).


Ok, we should now have internet available on our deployed instances. Let's continue and verify our fix is working fine.

### Deploy using python script and cli

We used horizon to deploy our first instance, this is cool, but it's still needs human intervention to do that.
However horizon is using the API and it is doing API calls in the background to the Openstack REST API.

So as an example, we will use a python script that will do the same things we did manually. The script will use python modules to interact with the REST API.

1. Connect to your lab controller using ssh.
2. Jump into the openstack_lab/devstack/common directory.
3. Edit `boot_cirros.py` file and change the line `auth_url = "http://192.168.27.100:35357/v2.0"` to point to your own endpoint.
4. Execute the script:
 python ./boot_cirros.py
![boot_cirros](img/boot_cirros_py.png)
5. Check the result on the horizon console. Quite cool isn't it ?
6. Connect  to your new instance using ssh and keys.
7. **Check if you can resolv internet addresses. If not, you failed in fixing the above issue and you just need to do it again or call the trainer if you are stuck.**

Well, we manage to drive our infrastructure using a python script, so it means we can do it from an application this is really powerful ! But, maybe you don't know about python (which is bad ;) ) . This is not an issue, bindings exists for other languages and of course applications have been developed to use that.


As an application example, we're going to do the same using the cli:
1. From controller, source our credentials and variables to access Openstack
 cd ~/openstack_lab/devstack/baremetal/
 source demo.openrc
2. You can see the variables defined using:
 env | grep OS
3. Go back into ~/openstack_lab/devstack/common and `cat boot_cirros.sh`.
4. Execute that script

As a result, we have a new instance called cirros-script running with a floating ip.

We can see the usage of 2 cli tools nova and openstack. Nova, cinder, glance, ..., tools are the old cli commands. The new way of managing Openstack is to use the `openstack` command. Because of this tool freshness, the latest command might not cover all the features compared to the old set of tools. So currently, we may have to use both.

### Deploy a bastion waystation

All the VM deployed on the private network cannot be reached from outside, unless a floating ip have been configured.

In order to make our automation easier not mapping/unmapping floating ip, we will deploy a bastion waystation that will relay ssh to the internal networks. This is also more secured, because we will expose from the outside of or cloud only the VMs that really require external access.

1. Jump into ~/openstack_lab/bastion
2. Launch `./bastion.sh`, it will deploy our bastion waystation attached to a floating ip.
3. Launch `./insternalvm.sh`, it will deploy a VM on private network only. Note : these are debian instances, so login: debian.
4. Connect first to the bastion waystation, then to the VM on the private network. You may experience some issue connecting to the VM on the private network.
![bastion_noagent](img/bastion_noagent.png)
5. The issue is due to ssh agent forwarding not loaded and default settings.
6. Load ssh-agent `eval $(ssh-agent)` and add key `ssh-add`.
7. Change the `/etc/ssh/ssh_config` setting to `ForwardAgent yes`.
8. Try to connect again, this should now work.
![bastion_agent](img/bastion_agent.png)

At that point, we can join our VM located on the private network, we will now configure the ssh proxy command. So we will be able to use ssh as usual and it will proxy our connection to the bastion host in the background.

1. To not use the proxy all the time, we will create a dedicated ssh_config client configuration. Copy your existing ssh_config: `cp /etc/ssh/ssh_config .`
2. Edit the local ssh_config file changing ProxyCommand to `ProxyCommand ssh -q -W %h:%p debian@172.24.9.24` of course ip should be your own bastion ip.
3. Try to connect directly to the VM on the internal subnet: `ssh -v -F ssh_config debian@10.0.0.37`, here we will use `-v` to show some debug message ensuring we are going through the proxy.
![bastion_proxy](img/bastion_proxy.png)


### Deploy Prestashop

We will now deploy an application, we will use Prestashop as an example. This is a php/mysql application.

We will deploy the following infrastructure:

* 1 x network to host our servers.
* 1 x security group associated that will allow ssh from private network to the Prestoshop one and http from outside.
* 1 x server apache + php engine.
* 1 x server mysql database.
* 1 x floating ip to the server.

Of course we could use a lot of tools to deploy our application (bash script, puppet, HPOO, cloudslang). Here we will choose:
* Heat, Openstack orchestration service to deploy the "infrastructure".
* Ansible, configuration management tool, to configure our servers according to our policies (packages, configuration files, ...).

Again, this is an implementation choice to show you 2 different tools. But combining those tools make sens and make the deployment convenient. (this is also because the author likes them ! ;) )

#### Configure ansible to use server names

Cloud instances are really easy to spawn. However each time you spawn an instance, the ip is changing.
So it is really difficult to rely on ip. We need to use names.

Ansible use a file to called inventory to describe nodes. Then the playbooks, which will be our recipe to configure hosts will use the inventory file. Although in such case, this is static inventory.

But, Ansible can also use a feature called dynamic inventory, an external provider can be configured to supply the host list and ip. Guess what ? A script is proposed on the Ansible [website](http://docs.ansible.com/ansible/intro_dynamic_inventory.html#example-openstack-external-inventory-script) to integrate it with Openstack.

We are going to configure that mechanism:

1. Jump into ~/openstack_lab/ansible 


ansible -vvvv -i invpriv.sh internalvm -m ping -u debian
