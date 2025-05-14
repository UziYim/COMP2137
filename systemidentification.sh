#!/bin/bash

# A script to display the current hostname, IP address, and gateway IP.

# Find and display the hostname
echo "Hostname: $(hostname)"

# Find and display the ip address (IPv4 address for the primary interface, which is the one that is used to reach the internet)
echo -n "My IP: "
ip route show default | awk '{print $9}'

# Find and display the gateway IP (AKA the default route router IP)
echo -n "Default Router: "
ip route show default | awk '{print $3}'

