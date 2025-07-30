#!/bin/bash
# Tell linux OS that we want to run this script using the correct interpreter

# Author: Thomas Chau
# Student No: 200622214

# Ignore termination signals so the script doesn't get interrupted accidentally
trap '' TERM HUP INT

# Initialize variables, left empty for flexibility
# Flag to control verbose output
VERBOSE=0
# Desired hostname
HOSTNAME=""
# Desired IP address
IPADDR=""
# Host entry name for /etc/hosts
HOSTENTRY_NAME=""
# Host entry IP for /etc/hosts
HOSTENTRY_IP=""

# Function to print messages only if verbose mode is enabled
log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo "$1"
    fi
}

# While-loop that parses CLI arguments and assigns values to variables
# Unrecognized options will then trigger an erro that exits the script
while [[ $# -gt 0 ]]; do
    case "$1" in
        -verbose)
            # Enable verbose output
            VERBOSE=1
            shift
            ;;
        -name)
            # Store desired hostname
            HOSTNAME="$2"
            shift 2
            ;;
        -ip)
            # Store desired IP address
            IPADDR="$2"
            shift 2
            ;;
        -hostentry)
            # Store host entry name
            HOSTENTRY_NAME="$2"
            # Store host entry IP
            HOSTENTRY_IP="$3"
            shift 3
            ;;
        *)
            # Catch invalid options
            echo "Unknown option: $1"
            # Exit the script if error is found
            exit 1
            ;;
    esac
done

# Update the system hostname if needed
if [ -n "$HOSTNAME" ]; then
    # Get current hostname
    CURRENT_HOSTNAME=$(hostname)
    if [ "$CURRENT_HOSTNAME" != "$HOSTNAME" ]; then
        # Update /etc/hostname file
        echo "$HOSTNAME" > /etc/hostname
        # Sets new hostname to variable entered
        hostnamectl set-hostname "$HOSTNAME"
        # Update /etc/hosts with the new hostname
        sed -i "s/$CURRENT_HOSTNAME/$HOSTNAME/g" /etc/hosts
        # Log the change of the hostname
        logger "Hostname changed from $CURRENT_HOSTNAME to $HOSTNAME"
        # Message that will say that the hostname has been updated to the desired hostname
        log_verbose "Hostname updated to $HOSTNAME"
    # Else that will say that the hostname is already set to the desired name
    else
        log_verbose "Hostname already set to $HOSTNAME"
    fi
fi

# Update the IP address if needed
if [ -n "$IPADDR" ]; then
    # Get the default network interface
    INTERFACE=$(ip route | grep default | awk '{print $5}')
    # Gets the current IP
    CURRENT_IP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    if [ "$CURRENT_IP" != "$IPADDR" ]; then
        # Remove old(current) IP from /etc/hosts
        sed -i "/$CURRENT_IP/d" /etc/hosts
        # Echo the new IP and hostname into /etc/hosts
        echo "$IPADDR $HOSTNAME" >> /etc/hosts
        
        # Find netplan config file
        NETPLAN_FILE=$(find /etc/netplan -name '*.yaml' | head -n 1)
        if [ -n "$NETPLAN_FILE" ]; then
            # Replace old IP with new in netplan
            sed -i "s/$CURRENT_IP/$IPADDR/" "$NETPLAN_FILE"
            netplan apply
            # Log the change
            logger "IP address changed from $CURRENT_IP to $IPADDR on $INTERFACE"  
            # Verbose message
            log_verbose "IP address updated to $IPADDR on $INTERFACE"
        # Else for if netplan file is missing
        else
            echo "Netplan config not found"
            exit 1
        fi
    # Else that will activate when the IP does not need to be changed
    else
        log_verbose "IP address already set to $IPADDR"
    fi
fi

# If statement to ensure the desired host entry is in /etc/hosts
if [ -n "$HOSTENTRY_NAME" ] && [ -n "$HOSTENTRY_IP" ]; then
    if ! grep -q "$HOSTENTRY_NAME" /etc/hosts || ! grep -q "$HOSTENTRY_IP" /etc/hosts; then
        # Delete any old entry for the name
        sed -i "/$HOSTENTRY_NAME/d" /etc/hosts
        # Add new host entry into /etc/hosts
        echo "$HOSTENTRY_IP $HOSTENTRY_NAME" >> /etc/hosts
        # Log the addition
        logger "Added host entry: $HOSTENTRY_IP $HOSTENTRY_NAME"
        # Verbose message
        log_verbose "Host entry added: $HOSTENTRY_IP $HOSTENTRY_NAME"
    # Else that will activate if it detects no change is needed
    else
        log_verbose "Host entry already exists: $HOSTENTRY_IP $HOSTENTRY_NAME"
    fi
fi

