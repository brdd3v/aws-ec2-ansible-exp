#!/bin/bash

# The selected AMI already has the SSM Agent preinstalled 

# Install Ansible
sudo apt-get update
sudo apt-get install ansible -y

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

