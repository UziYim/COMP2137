#!/bin/bash

# Function to create users with random passwords
create_user() {
  USERNAME=$1
  GROUP=$2
  PASSWORD=$(dd if=/dev/random count=1 status=none | base64 | dd bs=16 count=1 status=none)
  sudo useradd -m -g $GROUP $USERNAME
  echo "$USERNAME:$PASSWORD" | sudo chpasswd
  echo "User: $USERNAME | Password: $PASSWORD"
}

# Create users for each group
create_user coors brews
create_user stella brews
create_user michelob brews
create_user guiness brews

create_user oak trees
create_user pine trees
create_user cherry trees
create_user willow trees
create_user maple trees
create_user walnut trees
create_user ash trees
create_user apple trees

create_user chrysler cars
create_user toyota cars
create_user dodge cars
create_user chevrolet cars
create_user pontiac cars
create_user ford cars
create_user suzuki cars
create_user hyundai cars
create_user cadillac cars
create_user jaguar cars

create_user bill staff
create_user tim staff
create_user marilyn staff
create_user kevin staff
create_user george staff

create_user bob admins
create_user rob admins
create_user brian admins
create_user dennis admins
