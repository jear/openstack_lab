#!/bin/bash

openstack stack create hellostack -t hello_world.yaml --parameter "key_name=bastionkey;image=Debian Jessie 64-bit"
