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

# Exit script if any command fails
set -e

# Function to print error message and exit
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Check if the user is root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please switch to root or use sudo."
    exit 1
fi

# Welcome message
echo "=================================="
echo " Welcome to Nexus Setup by DrillDevOps!"
echo " Streamlining your repository management."
echo "=================================="

# Create Nexus user and configure sudoers
echo "Creating and configuring Nexus user..."
useradd nexus || true # Ignore if user already exists
usermod -aG nexus nexus || true
echo "nexus ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install Java 8
echo "Installing Java 8..."
yum install java-1.8.0-openjdk -y || error_exit "Failed to install Java 8."
yum install -y net-tools || error_exit "Failed to install net-tools."

# Set Java environment variables for nexus user
echo "Setting up Java environment..."
JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which java)))))
cat <<EOF >> ~nexus/.bashrc
export JAVA_HOME=$JAVA_HOME
export PATH=\$JAVA_HOME/bin:\$PATH
export INSTALL4J_JAVA_HOME=$JAVA_HOME
export PATH=\$INSTALL4J_JAVA_HOME/bin:\$PATH
EOF

# Download and install Nexus
echo "Installing Nexus..."
NEXUS_VERSION="3.63.0-01" # Replace <nexus-version> with actual version
NEXUS_DIR="/opt/nexus"
mkdir -p $NEXUS_DIR || error_exit "Failed to create Nexus directory."
yum install wget -y || error_exit "Failed to install wget."
wget https://download.sonatype.com/nexus/3/nexus-$NEXUS_VERSION-unix.tar.gz -P $NEXUS_DIR || error_exit "Failed to download Nexus."
tar -xzf $NEXUS_DIR/nexus-$NEXUS_VERSION-unix.tar.gz -C $NEXUS_DIR || error_exit "Failed to extract Nexus."
chown -R nexus:nexus $NEXUS_DIR || error_exit "Failed to set Nexus permissions."

# Start Nexus
echo "Starting Nexus..."
sudo su - nexus -c "$NEXUS_DIR/nexus-$NEXUS_VERSION/bin/nexus start" || error_exit "Failed to start Nexus."
sleep 60

# Check Nexus status
echo "Checking Nexus status..."
sudo su - nexus -c "$NEXUS_DIR/nexus-$NEXUS_VERSION/bin/nexus status" || error_exit "Failed to start Nexus."

echo "Nexus setup completed successfully."
