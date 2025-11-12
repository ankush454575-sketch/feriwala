#!/bin/bash

# Exit on any error
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Feriwala Deployment Script v2 ===${NC}"

# --- Step 1: Build the client and server locally ---
echo -e "${YELLOW}[STEP 1] Building the client...${NC}"
(cd client && npm install && npm run build)

echo -e "${YELLOW}[STEP 2] Building the server...${NC}"
(cd server && npm install && npm run build)

# --- Step 2: Package the application ---
echo -e "${YELLOW}[STEP 3] Packaging the application...${NC}"
rm -rf deploy
mkdir -p deploy/client/dist
mkdir -p deploy/server
cp -r client/dist/* deploy/client/dist/
cp server/package.json deploy/server/
cp server/package-lock.json deploy/server/
cp -r server/dist deploy/server/
cp .env.example deploy/server/.env 2>/dev/null || echo "MONGO_URL=your_mongodb_url" > deploy/server/.env

tar -czf deploy.tar.gz -C deploy .

# --- Step 3: Upload to Lightsail ---
echo -e "${YELLOW}[STEP 4] Uploading to Lightsail...${NC}"
scp -i "LightsailDefaultKey-ap-south-1.pem" deploy.tar.gz ubuntu@13.127.193.200:~/

# --- Step 4: SSH and Deploy with Node.js Installation ---
echo -e "${YELLOW}[STEP 5] Connecting to Lightsail and deploying...${NC}"
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 <<'REMOTESCRIPT'
set -ex

# --- Update system packages ---
sudo apt-get update
sudo apt-get upgrade -y

# --- Install Node.js 20 from NodeSource ---
echo "Installing Node.js v20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# --- Verify Node.js installation ---
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# --- Stop PM2 processes ---
echo "Stopping PM2 processes..."
. ~/.nvm/nvm.sh 2>/dev/null || true
pm2 stop all || true
pm2 kill || true

# --- Clean up previous deployment ---
echo "Cleaning up previous deployment..."
rm -rf ~/feriwala
mkdir -p ~/feriwala

# --- Extract the archive ---
echo "Extracting deployment package..."
cd ~
tar -xzf deploy.tar.gz -C ~/feriwala

# --- Install server dependencies ---
echo "Installing server dependencies..."
cd ~/feriwala/server
npm install --production

# --- Create .env file if it doesn't exist ---
if [ ! -f ~/.env.feriwala ]; then
  echo "Creating .env file..."
  cat > .env << 'ENVFILE'
MONGO_URL=mongodb+srv://ankush454563_db_user:Uufq8JEGONLwnj6S@cluster0.vwizt7t.mongodb.net/?appName=Cluster0
EMAIL_FOR_VERIFICATION=verify@feriwala.in
SMTP_SERVER=zoho.smtp.in
SMTP_PASSWORD=Y4SeYZPquzjf
NODE_ENV=production
PORT=3000
ENVFILE
else
  echo ".env already exists, skipping..."
fi

# --- Start the application with PM2 ---
echo "Starting application with PM2..."
pm2 start dist/index.js --name feriwala-server --env production --update-env
pm2 save
pm2 startup

# --- Configure nginx ---
echo "Configuring nginx..."
sudo tee /etc/nginx/sites-available/feriwala > /dev/null <<'NGINXFILE'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINXFILE

sudo ln -sf /etc/nginx/sites-available/feriwala /etc/nginx/sites-enabled/feriwala
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# --- Verify deployment ---
echo "Verifying deployment..."
sleep 3
pm2 status
pm2 logs feriwala-server --lines 10

echo "✅ Deployment complete!"
REMOTESCRIPT

echo -e "${GREEN}=== Deployment Successful ===${NC}"
echo -e "${GREEN}Your application is now live at: http://13.127.193.200${NC}"
echo -e "${YELLOW}Check status with: ssh -i 'LightsailDefaultKey-ap-south-1.pem' ubuntu@13.127.193.200 'pm2 status'${NC}"
