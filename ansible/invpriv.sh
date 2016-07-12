#!/bin/sh

# Wrapper around openstack.py to get instance public ip
./openstack.py --private $*
