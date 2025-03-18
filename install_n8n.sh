#!/bin/bash

# Request the domain name from the user
read -p "Enter your domain name (e.g., n8n.example.com): " DOMAIN_NAME

# Check if the domain name variable is empty
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: You didn't enter a domain name!"
    exit 1
fi

# Get the server IP address
SERVER_IP=$(ip addr show eth0 | grep inet | awk '{print $2}' | sed 's/\/.*//')

# Update the system
echo "Updating system..."
sudo apt update
sudo apt upgrade -y

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo apt install docker-compose -y

# Create the directory and docker-compose.yml file
echo "Creating the n8n directory and docker-compose.yml file..."
mkdir n8n
cd n8n
cat > docker-compose.yml <<EOL
version: "3.7"
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    environment:
      - N8N_HOST=$DOMAIN_NAME
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://$DOMAIN_NAME/
      - GENERIC_TIMEZONE=Asia/Tehran
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - nginxproxymanager_default

volumes:
  n8n_data:

networks:
  nginxproxymanager_default:
    external: true
EOL

# Run setting up DNS in Nginx Proxy Manager for the first time
echo "Running Nginx Proxy Manager ..."
sudo docker network create nginxproxymanager_default

# Run Docker Compose
echo "Starting n8n using Docker Compose..."
sudo docker compose up -d

echo "
--------------------------------------------------------------------
Initial n8n installation steps are complete!
--------------------------------------------------------------------

Please perform the following steps manually:

1. Open your server IP address in a web browser (with port 81 for Nginx Proxy Manager).
   The Nginx Proxy Manager interface can be accessed at: http://$SERVER_IP:81
2. In Nginx Proxy Manager, create a new Proxy Host for the domain $DOMAIN_NAME.
3. Create and apply an SSL certificate for your domain.

4. The IP address of your server is $SERVER_IP, to retrieve the IP manually you can use
```bash
ip addr show eth0 | grep inet | awk '{print $2}' | sed -E 's/\/.*//'
