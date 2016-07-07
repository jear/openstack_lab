
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


## Objectives of Lab
At the end of the Lab part one, students should be able to understand automation concept and be able to do their own automation scenario.

At the end of the Lab part two, students should be able to understand cloud native application concepts and be able to explain/apply some of them in their day to day job.

This Lab is intended to be trial and error so that during the session students should understand really what is behind the tools and concept, instead of blindly following instructions, which never teach people anything IMHO. You've been warned ;-)


## Reference documents

TBD

Estimated time for the lab is placed in front of each part.




# The infrastructure driven API (part 1)


### 2 words on Openstack

Openstack is a cloud solution to implement Infrastructure As A Service solution.

Key strengths :

* Drivers allow abstraction of the underlying physical infrastructure. Example, the way to create a persistent volume will be the same whatever the physical storage used (HPE, EMC).

* Standard defined API will allow automation whatever the tool/languages used.

* Opensource, all piece of code can be used, seen, modified.

## Environment description

Openstack suppliers (HPE, Redhat, Mirantis etc...) will bundle openstack upstream projects and create an Openstack distribution.

The one used in our lab is the devstack, this is "distribution" intended to develop Openstack.

In our lab we will use the devstack

