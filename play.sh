#! /bin/bash

v=
if [[ "X$1" == "Xv" ]]; then
    v='-vvv'
    export ANSIBLE_NOCOLOR=True
fi

export ANSIBLE_CACHE_PLUGIN=jsonfile
export ANSIBLE_CACHE_PLUGIN_CONNECTION=./cache
export ANSIBLE_PIPELINING=1
export ANSIBLE_SSH_PIPELINING=1

#rm -f ~/.ssh/known_hosts

ansible-playbook $v -i inv.yml --extra-vars @var.yml --extra-vars @pass.yml sync.yml
