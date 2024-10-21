#!/bin/bash

# Detect OS using lsb_release
OS=$(lsb_release -is 2>/dev/null || echo "non-ubuntu")

# Function to check if unzip is installed and install it if necessary
install_unzip() {
    if ! command -v unzip &> /dev/null
    then
        echo "Unzip could not be found. Installing unzip..."
        if [ "$OS" = "Ubuntu" ]; then
            sudo apt install unzip -y
        else
            sudo yum install unzip -y
        fi
    else
        echo "Unzip is already installed."
    fi
}

# Install unzip based on detected OS
install_unzip

# Download and install AWS CLI
echo "Downloading AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

echo "Unzipping AWS CLI..."
unzip awscliv2.zip

echo "Installing AWS CLI..."
sudo ./aws/install

# Check if AWS CLI is installed successfully
if aws --version &> /dev/null
then
    echo "AWS CLI installed successfully."
else
    echo "Failed to install AWS CLI."
    exit 1
fi

# Download the FortiEDR installation script from the S3 bucket
echo "Downloading FortiEDR installation script from S3..."
aws s3 cp s3://kbi-krom-isec-artifacts-main-prd-aps3-637423637300/fortiedr/FortiEDRSilentInstall_5.1.10.1024.sh .

# Run the installation script
echo "Running FortiEDR installation script..."
bash FortiEDRSilentInstall_5.1.10.1024.sh

# Check the status of fortiedr.service
echo "Checking status of fortiedr.service..."
SERVICE_STATUS=$(systemctl is-active fortiedr.service)

if [ "$SERVICE_STATUS" = "active" ]; then
    echo "FortiEDR service is running successfully."
else
    echo "FortiEDR service is not running. Status: $SERVICE_STATUS"
    systemctl status fortiedr.service
    exit 1
fi
