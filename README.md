# vxlan.sh

Creates VxLAN tunnels easily.

**Author**: Thomas Maurice - thomas@maurice.fr

# Introduction
This script allows you to create and define easily VxLAN tunnels with rather simple
configuration files. When you are done writing the file, just run the script, and your
two hosts will be able to communicate through the tunnel.

This script is runnable several times in a row, without any side effect (normally).

# Example
Let's say you have two hosts, `1.2.3.4` and `5.6.7.8`, and you want to setup a
tunnel between the two of them. We will assume that you want to use the VNI (equivalent
of the VLAN number) `42`, and want the tunnel to use port `3232`.

**Attention**: VxLAN use UDP, so you have to insert some rules in your firewall, like:
`iptables -A INPUT -p udp --dport 3232 -s 1.2.3.4 -j ACCEPT -m comment --comment 'vxlan tunnel'`

The first host will have the address 192.168.0.1/24, and the second one 192.168.0.2/24.

On the first host, you have to edit `/etc/vxlan_tunnels/tunnel`, and write down :
```
export IFACE=vx0
export BASE_IF=eth0
export VNI=42
export ADDRESS=192.168.0.1
export REMOTE_HOST=5.6.7.8
export REMOTE_PORT=3232
```

On the second one:

```
export IFACE=vx0
export BASE_IF=eth0
export VNI=42
export ADDRESS=192.168.0.2
export REMOTE_HOST=1.2.3.4
export REMOTE_PORT=3232
```

Run the script, `./vxlan.sh apply`, and you are done, you are now able to ping both of your hosts :)

Now you can use the tunnel for whatever you want, including routing all the trafic of one host to another, have fun !

# License
Seriously ?

