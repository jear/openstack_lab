#!/bin/bash

heat stack-create nenestack -f hello_world.yaml -P "admin_pass=Nene88;key_name=nene;image=cirros-0.3.4-x86_64-uec"
sleep 20s
heat output-show nenestack --all

