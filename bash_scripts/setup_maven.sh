#!/bin/bash

# Function to print messages
print_message() {
    echo "---------------------------"
    echo "$1"
    echo "---------------------------"
}

# Install required packages
print_message "Installing Git and wget"
yum install -y git wget

# Install Java 17 OpenJDK
print_message "Installing Java 17 OpenJDK"
yum install -y java-17-openjdk.x86_64

# Download and install Apache Maven
MAVEN_VERSION=3.9.9
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_DIR="/opt/apache-maven-${MAVEN_VERSION}"

print_message "Downloading Apache Maven version ${MAVEN_VERSION}"
wget -q ${MAVEN_URL} -P /tmp

print_message "Extracting Maven to /opt"
tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt

# Clean up the downloaded tar.gz file
rm -f /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz

# Setup environment variables
print_message "Configuring environment variables for Maven"
echo "export M2_HOME=${MAVEN_DIR}" >> ~/.bash_profile
echo 'export PATH=$M2_HOME/bin:$PATH' >> ~/.bash_profile

# Reload bash profile
source ~/.bash_profile

print_message "Maven installation and configuration completed"
