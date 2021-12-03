#! /bin/bash

export LC_ALL=C

update_hosts() {
    declare -A leases
    while read nu1 nu2 nu3 lease_host nu5; do
        leases["$lease_host"]='Y'
    done < /var/lib/misc/dnsmasq.leases

    mkdir -p /var/tmp/lxc-hosts

    lxc-ls -f -F NAME,IPV4 -1 --running | tail -n+2 | while read name ip other; do
        if [[ "${leases[$name]}" == 'Y' ]]; then
            continue
        fi
        ipn="${ip%,}"
        if ! [[ "$ipn" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            continue
        fi
        echo "$ipn"$'\t'"$name"
    done > /var/tmp/lxc-hosts/manual-hosts
}

update_hosts

lxc-monitor | while read msg; do
    if [[ "$msg" =~ 'changed state to [STOPPED]' ]]; then
        #echo SSS
        update_hosts
        continue
    fi
    if [[ "$msg" =~ 'changed state to [RUNNING]' ]]; then
        #echo RRR
        update_hosts
        continue
    fi
    #echo "$msg"
done
