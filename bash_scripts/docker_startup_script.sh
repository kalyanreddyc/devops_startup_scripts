#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright (c) [2024], [DrillDevOps, Owner/Author: Kalyan Kumar Reddy Chitiki]
# All rights reserved.

# Check if the user is root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please switch to root or use sudo."
    exit 1
fi

# Welcome message
echo "=========================================="
echo " Welcome to DrillDevOps's Docker Setup!"
echo " Simplifying your container management."
echo "=========================================="

# Exit script if any command fails
set -e

# Function to print error message and exit
error_exit()
{
    echo "$1" 1>&2
    exit 1
}

# Upgrade system packages
echo "Upgrading system packages..."
sudo yum upgrade -y || error_exit "Failed to upgrade system packages."

# Install necessary packages
echo "Installing required packages..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 || error_exit "Failed to install required packages."

# Add Docker repository
echo "Adding Docker repository..."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || error_exit "Failed to add Docker repository."

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker-ce docker-ce-cli containerd.io || error_exit "Failed to install Docker."

# Start Docker service
echo "Starting Docker service..."
sudo systemctl start docker || error_exit "Failed to start Docker service."

# Enable Docker to start on boot
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker || error_exit "Failed to enable Docker on boot."

# Check Docker status without interactive mode
echo "Checking Docker status..."
sudo systemctl is-active --quiet docker || error_exit "Docker is not running."

# Adding current user to docker group
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER || error_exit "Failed to add user to docker group."

echo "Docker setup completed successfully."
echo "You might need to logout and login again to use Docker without sudo."
