#!/bin/bash
#============ Variables ===============
# Conjur tenant
export CONJUR_ACCOUNT=conjur
# Conjur FQDN with schem and port
export CONJUR_APPLIANCE_URL=https://aws-pub-lab
# Conjur host/workload identity
export CONJUR_AUTHN_LOGIN=host/data/ansible/apps/conjur-demo
# Conjur host identity API key
export CONJUR_AUTHN_API_KEY=
# Conjur variable path
export CONJUR_VARIABLE_PATH=data/ansible/apps/safe/secret1
# Conjur public key file path, in case of Conjur cloud - comment line #14
# export CONJUR_CERT_FILE=/Users/Assaf.Hazan/git/cybr-demos/ansible/scripts/edge.pem
#========== Script ===============
# Loading functions snippet
ansible-playbook -i inventory playbook-ssh-key.yml -vv