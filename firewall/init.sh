#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2020
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

#set -o pipefail
set -o xtrace
#set -o errexit
set -o nounset

function setup_nic {
    nic_protected=eth0
    nic_unprotected=eth1
    ip_protected_addr=$(ip addr show $nic_protected | grep inet | awk '{print $2}')
    ip_unprotected_addr=$(ip addr show $nic_unprotected | grep inet | awk '{print $2}')

    vppctl create host-interface name "host-$nic_protected"
    vppctl create host-interface name "host-$nic_unprotected"

    vppctl set int ip address "host-$nic_protected" "$ip_protected_addr"
    vppctl set int ip address "host-$nic_unprotected" "$ip_unprotected_addr"

    vppctl set int state "host-$nic_protected" up
    vppctl set int state "host-$nic_unprotected" up
}

# Ensure VPP connection
attempt_counter=0
max_attempts=5
until vppctl show ver; do
    if [ ${attempt_counter} -eq ${max_attempts} ]; then
        echo "Max attempts reached"
        exit 1
    fi
    attempt_counter=$((attempt_counter + 1))
    sleep $((attempt_counter * 2))
done

# Configure VPP for vFirewall
setup_nic
brctl show
vppctl show hardware
vppctl show int addr

# Start HoneyComb
#/opt/honeycomb/honeycomb &>/dev/null &disown
/opt/honeycomb/honeycomb

# Start VES client
#/opt/VESreporting/vpp_measurement_reporter "$DCAE_COLLECTOR_IP" "$DCAE_COLLECTOR_PORT" eth1
