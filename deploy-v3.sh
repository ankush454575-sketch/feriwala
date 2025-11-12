#!/bin/bash

set -e

echo "=== Feriwala Deployment Script v3 (Improved) ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEPLOY_USER="ubuntu"
DEPLOY_HOST="13.127.193.200"
DEPLOY_KEY="LightsailDefaultKey-ap-south-1.pem"
DEPLOY_PATH="/home/ubuntu/feriwala"
TAR_FILE="deploy.tar.gz"

# Step 1: Build client
echo -e "${YELLOW}[STEP 1] Building the client...${NC}"
cd client
npm install
npm run build
cd ..

# Step 2: Build server
echo -e "${YELLOW}[STEP 2] Building the server...${NC}"
cd server
npm install
npm run build
cd ..

# Step 3: Create deployment package
echo -e "${YELLOW}[STEP 3] Packaging the application...${NC}"
rm -f $TAR_FILE
tar --exclude=node_modules --exclude=.env --exclude=dist -czf $TAR_FILE \
  client/dist \
  server/dist \
  server/package.json \
  server/package-lock.json

# Step 4: Upload to server
echo -e "${YELLOW}[STEP 4] Uploading to Lightsail...${NC}"
scp -i "$DEPLOY_KEY" -o "StrictHostKeyChecking=no" "$TAR_FILE" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"

# Step 5: Remote deployment with fixed Node.js installation
echo -e "${YELLOW}[STEP 5] Connecting to Lightsail and deploying...${NC}"

ssh -i "$DEPLOY_KEY" -o "StrictHostKeyChecking=no" "$DEPLOY_USER@$DEPLOY_HOST" << 'REMOTE_SCRIPT'

set -e

DEPLOY_PATH="/home/ubuntu/feriwala"
NODE_VERSION="20"

echo "=== Starting Remote Deployment ==="

# Create deployment directory
mkdir -p $DEPLOY_PATH
cd $DEPLOY_PATH

# Extract deployment package
echo "Extracting deployment package..."
tar -xzf deploy.tar.gz
rm deploy.tar.gz

# Fix Node.js installation issue - remove broken packages first
echo "Cleaning up any broken package installations..."
sudo dpkg --configure -a 2>/dev/null || true
sudo apt-get update

# Kill any existing Node.js processes
echo "Stopping any running Node.js processes..."
pm2 delete feriwala-server 2>/dev/null || true
pkill -f "node" || true
sleep 2

# Check if Node.js v20 is already installed
if ! command -v node &> /dev/null || [[ $(node -v) != *"v20"* ]]; then
    echo "Installing Node.js v20..."
    
    # Remove old Node.js completely
    sudo apt-get remove -y nodejs npm 2>/dev/null || true
    sudo apt-get autoremove -y 2>/dev/null || true
    
    # Add NodeSource repository and install Node.js v20
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    
    # Install with retries in case of network issues
    for i in {1..3}; do
        if sudo apt-get install -y nodejs; then
            break
        elif [ $i -lt 3 ]; then
            echo "Installation attempt $i failed. Retrying in 5 seconds..."
            sleep 5
        else
            echo "Failed to install Node.js after 3 attempts"
            exit 1
        fi
    done
fi

echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# Install server dependencies with correct Node version
echo "Installing server dependencies..."
cd $DEPLOY_PATH/server
npm install --production

# Create .env file for production
echo "Creating environment configuration..."
cat > .env << 'EOF'
MONGO_URL=mongodb+srv://ankush454563_db_user:Uufq8JEGONLwnj6S@cluster0.vwizt7t.mongodb.net/?appName=Cluster0
EMAIL_FOR_VERIFICATION=verify@feriwala.in
SMTP_SERVER=zoho.smtp.in
SMTP_PASSWORD=6u2Z05a0n5DnN7rL
NODE_ENV=production
PORT=3000
EOF

chmod 600 .env
echo "Environment configuration created"

# Ensure PM2 is installed globally
echo "Setting up PM2..."
sudo npm install -g pm2 2>/dev/null || true

# Start application with PM2
echo "Starting application with PM2..."
pm2 delete feriwala-server 2>/dev/null || true
pm2 start dist/index.js --name "feriwala-server" --env production
pm2 save
sudo env PATH=$PATH:/usr/local/bin pm2 startup ubuntu -u ubuntu --hp /home/ubuntu

# Verify application is running
echo "Verifying application..."
sleep 3
pm2 status

# Configure nginx as reverse proxy (if not already configured)
echo "Configuring nginx..."
if ! grep -q "feriwala" /etc/nginx/sites-available/default 2>/dev/null; then
    sudo tee /etc/nginx/sites-available/default > /dev/null << 'NGINX_CONFIG'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Serve static client files
    location /static/ {
        alias /home/ubuntu/feriwala/client/dist/;
        expires 1d;
        add_header Cache-Control "public, immutable";
    }
}
NGINX_CONFIG
    
    sudo systemctl restart nginx
    echo "Nginx configured and restarted"
else
    echo "Nginx already configured"
fi

echo -e "\n=== ${GREEN}Deployment Complete!${NC} ==="
echo "Application should be accessible at: http://13.127.193.200"
echo "PM2 logs: pm2 logs feriwala-server"
echo "To restart: pm2 restart feriwala-server"

REMOTE_SCRIPT

echo -e "${GREEN}[SUCCESS] Deployment completed!${NC}"
echo "Your application should now be running at: http://13.127.193.200"
echo ""
echo "Next steps:"
echo "  - Test the application: curl http://13.127.193.200"
echo "  - View logs: ssh -i \"$DEPLOY_KEY\" $DEPLOY_USER@$DEPLOY_HOST \"pm2 logs feriwala-server\""
echo "  - Restart app: ssh -i \"$DEPLOY_KEY\" $DEPLOY_USER@$DEPLOY_HOST \"pm2 restart feriwala-server\""
