#!/bin/bash

# vxlan.sh
# Author: Thomas Maurice <thomas@maurice.fr>
#
# Small script to create VxLAN tunnels simply.
# 
# Define your tunnels as defined in the examples/ directory and run the script
# it will create and up the tunnel. This script sould be runnable several times
# in a row, without any side effect.

set -e

function log () {
    echo -e "\e[1;37m[`date +"%D %H:%M:%S"`] \e[0;37m$*\e[0m"
}

function error () {
    echo -e "\e[1;31m[`date +"%D %H:%M:%S"`] \e[0;37m$*\e[0m"
}

function success () {
    echo -e "\e[1;32m[`date +"%D %H:%M:%S"`] \e[0;37m$*\e[0m"
}

function info() {
    echo -e "\e[1;34m[`date +"%D %H:%M:%S"`] \e[0;37m$*\e[0m"
}

VXLAN_DIR=/etc/default/vxlan_tunnels

if [ "$1" == "show" ]; then
    for tunnel in `ls -1 $VXLAN_DIR`; do
        info "Tunnel: $tunnel"
        info "--------------------------------"
        unset IFACE BASE_IF VNI REMOTE_PORT REMOTE_HOST
        source $VXLAN_DIR/$tunnel
        if [ -z ${IFACE+x} ];       then error " * IFACE is unset !"; else success " * IFACE: $IFACE"; fi
        if [ -z ${BASE_IF+x} ];     then error " * BASE_IF is unset !"; else success " * BASE_IF: $BASE_IF"; fi
        if [ -z ${VNI+x} ];         then error " * VNI is unset !"; else success " * VNI: $VNI"; fi
        if [ -z ${ADDRESS+x} ];     then error " * ADDRESS is unset !"; else success " * ADDRESS: $ADDRESS"; fi
        if [ -z ${REMOTE_HOST+x} ]; then error " * REMOTE_HOST is unset !"; else success " * REMOTE_HOST: $REMOTE_HOST"; fi
        if [ -z ${REMOTE_PORT+x} ]; then error " * REMOTE_PORT is unset !"; else success " * REMOTE_PORT: $REMOTE_PORT"; fi
    done;
elif [ "$1" == "apply" ]; then
    for tunnel in `ls -1 $VXLAN_DIR`; do
        info "Setting up tunnel: $tunnel"
        info "--------------------------------"
        unset IFACE BASE_IF VNI REMOTE_PORT REMOTE_HOST
        source $VXLAN_DIR/$tunnel

        if [ -z ${IFACE+x} ];       then error "IFACE is unset !"; continue; fi
        if [ -z ${BASE_IF+x} ];     then error "BASE_IF is unset !"; continue; fi
        if [ -z ${VNI+x} ];         then error "VNI is unset !"; continue; fi
        if [ -z ${ADDRESS+x} ];         then error "ADDRESS is unset !"; continue; fi
        if [ -z ${REMOTE_HOST+x} ]; then error "REMOTE_HOST is unset !"; continue; fi
        if [ -z ${REMOTE_PORT+x} ]; then error "REMOTE_PORT is unset !"; continue; fi

        info "Ensuring the vxlan interface $IFACE exists"
        if ! /sbin/ip link show $IFACE >>/dev/null 2>&1; then
            /sbin/ip link add $IFACE type vxlan id $VNI dev $BASE_IF remote $REMOTE_HOST dstport $REMOTE_PORT
            success "$IFACE created !"
        fi;
        info "Forcing address for $IFACE to $ADDRESS"
        /sbin/ip address change dev $IFACE $ADDRESS
        if /sbin/ip address show $IFACE | grep -q "inet $ADDRESS"; then
            success "Address changed to $ADDRESS for device $IFACE"
        else
            error "Failed to set address $ADDRESS to device $IFACE"
        fi;
        info "Setting link up"
        /sbin/ip link set up $IFACE
    done;
fi;
