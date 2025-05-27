#!/bin/bash

# Add dennis to all groups
sudo usermod -aG brews,trees,cars,staff,admins dennis

# Grant sudo privileges
echo "dennis ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/dennis

