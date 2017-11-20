#!/bin/bash

# assume that the server is up and running

# get the server ip address to configure ansible

srv01_ip=$(terraform output srv01-ip)
cat > ansible/files/hosts <<EOF
[aws]
$srv01_ip
EOF

# launch preparation of the server with ansible
#
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ansible/playbooks/prepare.yml -i ansible/files/hosts

#
#
