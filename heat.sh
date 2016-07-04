#!/bin/bash

heat stack-create nenestack -f hello_world.yaml -P "admin_pass=Nene88;key_name=nene;image=cirros-0.3.4-x86_64-uec"
sleep 20s
heat output-show nenestack --all
heat stack-create nenestack2 -f servers_in_existing_neutron_net.yaml -P "key_name=nene;image=cirros-0.3.4-x86_64-uec;public_net_id=a3dba3d1-7032-4aeb-9b67-eabd4de62eca;private_net_id=647e4cbe-6a95-422c-a5fd-a48c5ae821f1;flavor=m1.tiny;private_subnet_id=5d198962-8342-41f5-b6f7-58200f5a137b"
