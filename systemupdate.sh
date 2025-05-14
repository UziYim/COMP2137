#!/bin/bash

# A script to update the operating system software. It should not ask the person running the script any questions, although it may need the user to enter a password for sudo use. 

# Run update to ensure we are online and have the latest software list

sudo apt update

# Upgrade the software packages

sudo apt upgrade -y
