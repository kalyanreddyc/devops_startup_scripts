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
echo " Welcome to DrillDevOps's Maven Setup!"
echo " Simplifying your build management."
echo "=========================================="

# Exit script if any command fails
set -e

# Function to print error message and exit
error_exit()
{
    echo "$1" 1>&2
    exit 1
}

# Install Java 17
echo "Installing Java 17..."
sudo yum install java-17-openjdk.x86_64 -y || error_exit "Failed to install Java 17."

# Install wget if not already installed
echo "Installing wget..."
sudo yum install wget -y || error_exit "Failed to install wget."

# Download and install Apache Maven
MAVEN_VERSION="3.9.8"
MAVEN_DIR="/opt/maven"
MAVEN_TAR="apache-maven-$MAVEN_VERSION-bin.tar.gz"
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/$MAVEN_TAR"

echo "Downloading Apache Maven..."
sudo wget "$MAVEN_URL" || error_exit "Failed to download Apache Maven."

echo "Extracting Apache Maven..."
sudo tar -xvzf "$MAVEN_TAR" || error_exit "Failed to extract Apache Maven."

echo "Creating Maven directory..."
sudo mkdir -p "$MAVEN_DIR" || error_exit "Failed to create Maven directory."

echo "Copying Maven files to /opt/maven..."
sudo cp -r "apache-maven-$MAVEN_VERSION"/* "$MAVEN_DIR" || error_exit "Failed to copy Maven files."

echo "Cleaning up..."
sudo rm -rf "apache-maven-$MAVEN_VERSION" || error_exit "Failed to clean up Maven files."
sudo rm -f "$MAVEN_TAR" || error_exit "Failed to remove Maven tar file."

# Set up environment variables
echo "Configuring environment variables..."
cat <<EOL >> ~/.bashrc
# Apache Maven Environment Variables
export M2_HOME=$MAVEN_DIR
export PATH=\$M2_HOME/bin:\$PATH
EOL

# Reload bashrc
echo "Reloading .bashrc..."
source ~/.bashrc || error_exit "Failed to reload .bashrc."

# Verify Maven installation
echo "Verifying Maven installation..."
mvn --version || error_exit "Maven installation failed."

echo "Apache Maven setup completed successfully."
