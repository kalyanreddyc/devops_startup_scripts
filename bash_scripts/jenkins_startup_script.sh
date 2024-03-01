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
echo "======================================="
echo " Welcome to DrillDevOps's Jenkins Setup!"
echo " Empowering your DevOps journey with ease."
echo "======================================="


# Exit script if any command fails
set -e

# Function to print error message and exit
error_exit()
{
    echo "$1" 1>&2
    exit 1
}

# Upgrade system if necessary
echo "Checking and upgrading system packages..."
sudo yum upgrade -y || error_exit "Failed to upgrade system packages."

# Install wget if not already installed
if ! yum list installed wget &>/dev/null; then
    echo "Installing wget..."
    sudo yum install wget -y || error_exit "Failed to install wget."
else
    echo "wget is already installed."
fi

# Install Java if not already installed
JAVA_PKG="java-17-openjdk"
if ! yum list installed "$JAVA_PKG" &>/dev/null; then
    echo "Installing Java..."
    sudo yum install "$JAVA_PKG" -y || error_exit "Failed to install Java."
else
    echo "Java is already installed."
fi

# Install Maven if not already installed
MAVEN_VERSION="apache-maven-3.9.6"
MAVEN_DIR="/opt/maven"
MAVEN_TAR="$MAVEN_DIR/$MAVEN_VERSION-bin.tar.gz"
MAVEN_INSTALLED=false
if [ ! -d "$MAVEN_DIR/$MAVEN_VERSION" ]; then
    echo "Installing Maven..."
    mkdir -p "$MAVEN_DIR" || error_exit "Failed to create Maven directory."
    if [ ! -f "$MAVEN_TAR" ]; then
        wget -O "$MAVEN_TAR" "https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/$MAVEN_VERSION-bin.tar.gz" || error_exit "Failed to download Maven."
    fi
    tar -xzf "$MAVEN_TAR" -C "$MAVEN_DIR" || error_exit "Failed to extract Maven."
    MAVEN_INSTALLED=true
else
    echo "Maven is already installed."
fi

# Set Maven environment variables only if Maven was just installed
if [ "$MAVEN_INSTALLED" = true ]; then
    echo "Setting Maven environment variables..."
    {
        echo "export MAVEN_HOME=$MAVEN_DIR/$MAVEN_VERSION"
        echo 'export PATH=$MAVEN_HOME/bin:$PATH'
    } >> /etc/profile.d/maven.sh || error_exit "Failed to write Maven environment setup."
fi

# Install Git if not already installed
if ! yum list installed git &>/dev/null; then
    echo "Installing Git..."
    sudo yum install git -y || error_exit "Failed to install Git."
else
    echo "Git is already installed."
fi

# Set Jenkins operations to be handled by Jenkins user
JENKINS_PKG="jenkins"
if ! yum list installed "$JENKINS_PKG" &>/dev/null; then
    echo "Setting up Jenkins repository..."
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo || error_exit "Failed to add Jenkins repo."
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key || error_exit "Failed to import Jenkins key."
    
    echo "Installing Jenkins..."
    sudo yum install "$JENKINS_PKG" -y || error_exit "Failed to install Jenkins."

    # Ensure Jenkins service runs under jenkins user, usually handled by default
else
    echo "Jenkins is already installed."
fi

# Start and enable Jenkins service, ensuring proper permissions
echo "Configuring Jenkins service..."
sudo systemctl daemon-reload || error_exit "Failed to reload system daemons."
sudo systemctl enable jenkins || error_exit "Failed to enable Jenkins service."
sudo systemctl start jenkins || error_exit "Failed to start Jenkins service."

# Check if Jenkins service is active
if ! systemctl is-active --quiet jenkins; then
    error_exit "Jenkins service failed to start."
else
    echo "Jenkins service started and enabled."
fi

echo "Installation and setup completed successfully."
