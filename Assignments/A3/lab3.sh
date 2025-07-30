#!/bin/bash
# This script runs the configure-host.sh script on 2 servers and updates the local /etc/hosts file

# Note, I wasn't sure if we were meant to add comments to this script or not but I added it anyways -TC

VERBOSE_FLAG=""
# For loop to check if -verbose was used in the cli argument when running the script
for arg in "$@"; do
    # Check if the exact argument -verbose was used
    if [[ "$arg" == "-verbose" ]]; then
        VERBOSE_FLAG="-verbose"
        # If argument is found then break out of loop
        break
    fi
done

# Function to handle error
handle_error() {
    # Echo the error message
    echo "ERROR: $1"
    # Exit/Stops the script
    exit 1
}
echo "--For Server 1--"
scp configure-host.sh remoteadmin@server1-mgmt:/root || handle_error "Failed to copy to server1"
# handle_error function will check if the command fails, handle_error will then report the failure
ssh remoteadmin@server1-mgmt -- "sudo /root/configure-host.sh $VERBOSE_FLAG -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4" || handle_error "Failed to configure server1"

echo "--For Server 2--"
scp configure-host.sh remoteadmin@server2-mgmt:/root || handle_error "Failed to copy to server2"
# handle_error function will check if the command fails, handle_error will then report the failure
ssh remoteadmin@server2-mgmt -- "sudo /root/configure-host.sh $VERBOSE_FLAG -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3" || handle_error "Failed to configure server2"

# handle_error functions will wait to see if either update fails, handle_error will then report the failure
sudo ./configure-host.sh $VERBOSE_FLAG -hostentry loghost 192.168.16.3 || handle_error "Failed to update local loghost"
sudo ./configure-host.sh $VERBOSE_FLAG -hostentry webhost 192.168.16.4 || handle_error "Failed to update local webhost"

echo "--End Of Script--"

