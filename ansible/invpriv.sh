#!/bin/sh

# Wrapper around openstack.py to get instance public ip
curdir=$(pwd)

cd $(dirname $0)
./openstack.py --private $*
cd $curdir
