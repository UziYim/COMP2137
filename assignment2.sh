#!/bin/bash
# Indicates that we are using bash to execute the following script to the linux system

# Author: Thomas Chau
# Student No: 200622214

# Will exit the script if it eencounters any command fails
set -e

# Define values
# Desired target ip of server1
target_ip="192.168.16.21"
# Netplan configuration file that will be modified
netplan_file="/etc/netplan/50-cloud-init.yaml"
# Gives a name to the following ip address
hostname="server1"
# List of users that will be created
users=(dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda)
# SSH key for dennis user
ssh_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

# Netplan configuration
# Checks whether or not the netplan file is already configured with the target ip using an if statement
if grep -q "$target_ip" "$netplan_file"; then
	echo "The netplan has already been configured with $target_ip"
# Else will run if the if returns false
else
	# Overwrite the netplan file with the following configuration
	cat <<EOF > "$netplan_file"
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [$target_ip/24]
      gateway4: 192.168.16.2
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
# Indicate End Of File
EOF
	# Apply the network configuration
	netplan apply

# Close if statement
fi

# Update hosts file
# Search for any file within the hostname and delete it to avoid any duplicates
sed -i "/$hostname/d" /etc/hosts
# Add ip address and hostname to /etc/hosts
echo "$target_ip $hostname" >> /etc/hosts

# For-loop that will check and install the apache2 agnd squid packages if needed
for pkg in apache2 squid; do
	# Check to see if the package is installed or not, if not then the if statement will run
	if ! dpkg -s "$pkg" &>/dev/null; then

		# Get update and hides the package list from being shown in CLI
		apt-get update -qq
		# Install update and automatically confirms the prompt to install
		apt-get install -y "$pkg"	
	# Else statement that runs only if the packages are already installed	
	else
	# Tell user that the packages have already been installed
	echo "The packages are already installed"
	# End if statement
	fi
# Close for loop
done

# User accounts setup
# loop through each user in the users list
for user in "${users[@]}"; do
	# Check to see if the user exists already, will run if they do not
	if ! id "$user" &>/dev/null; then
		# Add the non-existant user with a home directory and bash shell
		useradd -m -s /bin/bash "$user"
	else
	# Tells user that the user(s) already exists 
	echo "User $user already exists"
	# Close if statement
	fi

	# Define paths for SSH config
	home_directory="/home/$user"
	ssh_directory="$home_directory/.ssh"
	auth_keys="$ssh_directory/authorized_keys"
	
	# Create ssh directory and set permissions
	mkdir -p "$ssh_directory"
	chown "$user:$(id -gn "$user")" "$ssh_directory"
	chmod 700 "$ssh_directory"
	
	# Check if rsa-key has not been created yet. Statement will run if not created
	if [ ! -f "$ssh_directory/id_rsa.pub" ]; then
		# Generate rsa-key and set to 2048 bit size, specify file path and sets no password (Fail safe to enter blank string if command is to fail)
		sudo -u "$user" ssh-keygen -t rsa -b 2048 -f "$ssh_directory/id_rsa" -N "" || echo ""
	fi
	
	# Check if ED25519 key is not created yet. Statement will run if not created
	if [ ! -f "$ssh_directory/id_ed25519.pub" ]; then
		# Generate ED25519 key, specify file path and sets no password (Fail safe here to activate if command fails)
		sudo -u "$user" ssh-keygen -t ed25519 -f "$ssh_directory/id_ed25519" -N "" || echo ""
	fi

	# Insert keys into authorized_keys file
	cat "$ssh_directory/id_rsa.pub" "$ssh_directory/id_ed25519.pub" > "$auth_keys"
	
	# Check if username matches dennis
	if [ "$user" == "dennis" ]; then
		# Check if dennis user does not have additional public key. Statement will run if not added
		if ! grep -q "$ssh_key" "$auth_keys"; then
			# Add key to authorized_keys file
			echo "$ssh_key" >> "$auth_keys"
		fi
		# Add user dennis to sudo group to allow admin privileges
		usermod -aG sudo dennis
	fi
	
	# Set permissions for authorized_keys file (Read + Write)
	chmod 600 "$auth_keys"
	# Set ownerhsip for authorized_keys file
	chown -R "$user:$(id -gn "$user")" "$ssh_directory"
	
# Close for loop
done

# Completion message
echo "Script complete"
