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
echo " Welcome to DrillDevOps's AWS CLI Setup!"
echo " Simplifying your AWS management."
echo "=========================================="

# Exit script if any command fails
set -e

# Function to print error message and exit
error_exit()
{
    echo "$1" 1>&2
    exit 1
}

# Install necessary packages
echo "Installing required packages..."
sudo yum install curl unzip -y || error_exit "Failed to install curl and unzip."

# Download AWS CLI
AWS_CLI_ZIP="awscliv2.zip"
AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

echo "Downloading AWS CLI..."
curl "$AWS_CLI_URL" -o "$AWS_CLI_ZIP" || error_exit "Failed to download AWS CLI."

# Unzip AWS CLI
echo "Unzipping AWS CLI..."
unzip "$AWS_CLI_ZIP" || error_exit "Failed to unzip AWS CLI."

# Install AWS CLI
echo "Installing AWS CLI..."
sudo ./aws/install || error_exit "Failed to install AWS CLI."

# Clean up
echo "Cleaning up..."
rm -rf aws || error_exit "Failed to remove AWS CLI installation directory."
rm -f "$AWS_CLI_ZIP" || error_exit "Failed to remove AWS CLI ZIP file."

# Verify AWS CLI installation
echo "Verifying AWS CLI installation..."
aws --version || error_exit "AWS CLI installation failed."

echo "AWS CLI setup completed successfully."
