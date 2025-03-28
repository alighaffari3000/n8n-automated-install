#!/bin/bash

# Request the domain name from the user
read -p "Enter your domain name (e.g., n8n.example.com): " DOMAIN_NAME

# Check if the domain name variable is empty
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: You didn't enter a domain name!"
    exit 1
fi

# Get the server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Check if an IP address was found
if [ -z "$SERVER_IP" ]; then
    echo "Error: Could not determine the server's IP address.  Please ensure hostname -I is working and returns an IP."
    exit 1
fi

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

# Install Nginx Proxy Manager
echo "Installing Nginx Proxy Manager..."
mkdir nginx-proxy-manager
cd nginx-proxy-manager
cat > docker-compose.yml <<EOL
version: '3.7'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOL
docker compose up -d

# Create the directory and docker-compose.yml file for N8N
echo "Creating the n8n directory and docker-compose.yml file..."
cd ..
mkdir n8n
cd n8n
# Use echo to create the file
echo "version: \"3.7\"" > docker-compose.yml
echo "services:" >> docker-compose.yml
echo "  n8n:" >> docker-compose.yml
echo "    image: docker.n8n.io/n8nio/n8n" >> docker-compose.yml
echo "    restart: always" >> docker-compose.yml
echo "    environment:" >> docker-compose.yml
echo "      - N8N_HOST=$DOMAIN_NAME" >> docker-compose.yml
echo "      - N8N_PORT=5678" >> docker-compose.yml
echo "      - N8N_PROTOCOL=https" >> docker-compose.yml
echo "      - NODE_ENV=production" >> docker-compose.yml
echo "      - WEBHOOK_URL=https://$DOMAIN_NAME/" >> docker-compose.yml
echo "      - GENERIC_TIMEZONE=Asia/Tehran" >> docker-compose.yml
echo "    volumes:" >> docker-compose.yml
echo "      - n8n_data:/home/node/.n8n" >> docker-compose.yml
echo "    networks:" >> docker-compose.yml
echo "      - nginxproxymanager_default" >> docker-compose.yml
echo "" >> docker-compose.yml
echo "volumes:" >> docker-compose.yml
echo "  n8n_data:" >> docker-compose.yml
echo "" >> docker-compose.yml
echo "networks:" >> docker-compose.yml
echo "  nginxproxymanager_default:" >> docker-compose.yml
echo "    external: true" >> docker-compose.yml


# Run setting up DNS in Nginx Proxy Manager for the first time
echo "Running Nginx Proxy Manager ..."
sudo docker network create nginxproxymanager_default

# Run Docker Compose
echo "Starting n8n using Docker Compose..."
sudo docker compose up -d

echo "
--------------------------------------------------------------------
Initial Nginx Proxy Manager and n8n installation steps are complete!
--------------------------------------------------------------------

Please perform the following steps manually:

1. Open your server IP address in a web browser (with port 81 for Nginx Proxy Manager).
   The Nginx Proxy Manager interface can be accessed at: http://$SERVER_IP:81
2. In Nginx Proxy Manager, create a new Proxy Host for the domain $DOMAIN_NAME.
3. Create and apply an SSL certificate for your domain.

4. The IP address of your server is $SERVER_IP, to retrieve the IP manually you can use
```bash
ip addr show eth0 | grep inet | awk '{print $2}' | sed -E 's/\/.*//'
