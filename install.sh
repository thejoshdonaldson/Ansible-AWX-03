#!/bin/bash

# Update and install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y git curl ansible-core build-essential

# Install k3s
echo "Installing k3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.5+k3s1 sh -s - --write-kubeconfig-mode 644

# Clone the Git repository
echo "Cloning the Git repository..."
git clone https://github.com/maniak-academy/guide-k3s-awx-tower.git
cd guide-k3s-awx-tower

# Apply Kubernetes configurations
echo "Applying Kubernetes configurations..."
kubectl apply -k operator

# Set up AWX host and generate certificates
echo "Setting up AWX host and generating certificates..."
AWX_HOST="awx.josh.com"
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out ./base/tls.crt -keyout ./base/tls.key -subj "/CN=${AWX_HOST}/O=${AWX_HOST}" -addext "subjectAltName = DNS:${AWX_HOST}"

# Create directories for Postgres and projects
echo "Creating directories for Postgres and projects..."
sudo mkdir -p /data/postgres-13
sudo mkdir -p /data/projects
sudo chmod 755 /data/postgres-13
sudo chown 1000:0 /data/projects

# Apply base Kubernetes configurations
echo "Applying base Kubernetes configurations..."
kubectl apply -k base

# Output the AWX URL, username, and password
echo "Setup complete."
echo "AWX URL: https://awx.josh.lab"
echo "Username: admin"
echo "Password: Ansible123!"

# Print out Kubernetes resources in the 'awx' namespace
echo "The deployment takes a couple minutes to complete. Run the following command to check the status:"

echo " "
echo "When its complete 2-5 minutes later, execute the following commands"
echo " *********** "
echo "AWX_INGRESS_IP=$(kubectl -n awx get ingress awx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "AWX Ingress IP Address: $AWX_INGRESS_IP"

# DNS Setup instructions
echo "Please set up DNS to point to the AWX Ingress IP Address."
echo "Add a DNS A record for ${AWX_HOST} pointing to $AWX_INGRESS_IP"
