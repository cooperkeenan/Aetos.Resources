#!/bin/bash
# Create this file: modules/vm/setup.sh

set -e

# Update system
apt-get update
apt-get upgrade -y

# Install required packages for your scraper
apt-get install -y docker.io git curl sqlite3

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add azureuser to docker group
usermod -aG docker azureuser

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Download your existing run.sh script from GitHub
echo "Downloading run.sh script..."
wget -O /home/azureuser/run.sh https://raw.githubusercontent.com/${github_user}/${repo_name}/${branch}/scripts/run.sh
chmod +x /home/azureuser/run.sh
chown azureuser:azureuser /home/azureuser/run.sh

# Create systemd service that runs your existing script
cat > /etc/systemd/system/${service_name}.service << EOF
[Unit]
Description=Facebook Scraper Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
User=azureuser
WorkingDirectory=/home/azureuser
ExecStart=/home/azureuser/run.sh

[Install]
WantedBy=multi-user.target
EOF

# Enable service (but don't auto-start - you'll run it manually or via cron)
systemctl daemon-reload
systemctl enable ${service_name}

echo "Setup completed successfully!"
echo "Your run.sh script is ready at: /home/azureuser/run.sh"
echo "Run with: sudo systemctl start ${service_name}"