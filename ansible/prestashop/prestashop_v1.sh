#!/bin/sh

# Deploy prestashop
ansible-playbook -vvvv prestashop_infra_v1.yaml
ansible-playbook -vvvv prestashop_app_v1.yaml
