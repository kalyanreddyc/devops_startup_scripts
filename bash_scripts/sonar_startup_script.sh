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
echo " Welcome to DrillDevOps's SonarQube Setup!"
echo " Enhancing your code quality with precision."
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
echo "Installing wget and unzip..."
sudo yum install wget unzip -y || error_exit "Failed to install wget and unzip."

# Check if Java 17 is installed
JAVA_PKG="java-17-openjdk.x86_64"
if ! rpm -q --quiet "$JAVA_PKG"; then
    echo "Java 17 is not installed. Installing Java 17..."
    sudo yum install "$JAVA_PKG" -y || error_exit "Failed to install Java 17."
else
    echo "Java 17 is already installed."
fi

# Download SonarQube
SONARQUBE_VERSION="sonarqube-10.2.1.78527"
SONARQUBE_DIR="/opt/sonarqube"
SONARQUBE_ZIP="$SONARQUBE_VERSION.zip"
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/$SONARQUBE_ZIP"

echo "Setting up SonarQube..."
sudo mkdir -p "$SONARQUBE_DIR" || error_exit "Failed to create SonarQube directory."
if [ ! -f "$SONARQUBE_DIR/$SONARQUBE_ZIP" ]; then
    sudo wget -O "$SONARQUBE_DIR/$SONARQUBE_ZIP" "$SONARQUBE_URL" || error_exit "Failed to download SonarQube."
fi

# Unzip SonarQube
echo "Unzipping SonarQube..."
sudo unzip -o "$SONARQUBE_DIR/$SONARQUBE_ZIP" -d "$SONARQUBE_DIR" || error_exit "Failed to unzip SonarQube."
sudo mv "$SONARQUBE_DIR/$SONARQUBE_VERSION" "$SONARQUBE_DIR/sonarqube" || error_exit "Failed to rename SonarQube directory."
sudo rm -f "$SONARQUBE_DIR/$SONARQUBE_ZIP" || error_exit "Failed to remove SonarQube ZIP file."

# Create SonarQube user and set permissions
echo "Configuring SonarQube user and permissions..."
if ! id sonar &>/dev/null; then
    sudo useradd sonar || error_exit "Failed to create SonarQube user."
fi
sudo chown -R sonar:sonar "$SONARQUBE_DIR" || error_exit "Failed to set SonarQube directory permissions."

# Start SonarQube
echo "Starting SonarQube..."
sudo su - sonar -c "$SONARQUBE_DIR/sonarqube/bin/linux-x86-64/sonar.sh start" || error_exit "Failed to start SonarQube."

# Check SonarQube status
echo "Checking SonarQube status..."
sudo su - sonar -c "$SONARQUBE_DIR/sonarqube/bin/linux-x86-64/sonar.sh status" || error_exit "Failed to check SonarQube status."

echo "SonarQube setup completed successfully."
