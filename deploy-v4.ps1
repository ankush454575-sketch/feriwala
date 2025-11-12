# deploy-v4.ps1

# This script is a PowerShell equivalent of deploy-v4.sh

# Stop on error
$ErrorActionPreference = "Stop"

Write-Host "=== Feriwala Deployment Script v4 (Final) ===" -ForegroundColor Green

# Colors for output (PowerShell equivalent)
$RED = "`e[0;31m"
$GREEN = "`e[0;32m"
$YELLOW = "`e[1;33m"
$NC = "`e[0m" # No Color

# Configuration
$DEPLOY_USER = "ubuntu"
$DEPLOY_HOST = "13.127.193.200"
$DEPLOY_KEY = "LightsailDefaultKey-ap-south-1.pem"
$DEPLOY_PATH = "/home/ubuntu/feriwala"
$TAR_FILE = "deploy.tar.gz"

# Step 1: Build client
Write-Host "$($YELLOW)[STEP 1] Building the client...$($NC)"
Set-Location client
npm install
npm run build
Set-Location ..

# Step 2: Build server
Write-Host "$($YELLOW)[STEP 2] Building the server...$($NC)"
Set-Location server
npm install
npm run build
Set-Location ..

# Step 3: Create deployment package (WITHOUT node_modules to rebuild on server)
Write-Host "$($YELLOW)[STEP 3] Packaging the application...$($NC)"
Remove-Item $TAR_FILE -ErrorAction SilentlyContinue
# tar command equivalent in PowerShell is more complex.
# For now, we'll assume tar.exe is available in the PATH or use a workaround.
# This part needs careful translation.
# For now, I'll use the tar.exe if available, otherwise, this will fail.
# A more robust solution would be to use a .NET compression library or a PowerShell module.
# Given the environment is MINGW64, tar.exe might be available.
tar --exclude=node_modules --exclude=.env --exclude=dist -czf $TAR_FILE `
  client/dist `
  server/dist `
  server/package.json `
  server/package-lock.json

# Step 4: Upload to server
Write-Host "$($YELLOW)[STEP 4] Uploading to Lightsail...$($NC)"
# scp command equivalent in PowerShell
# This assumes scp.exe is available in the PATH.
scp -i "$DEPLOY_KEY" -o "StrictHostKeyChecking=no" "$TAR_FILE" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"

# Step 5: Remote deployment with proper Node.js setup and rebuild
Write-Host "$($YELLOW)[STEP 5] Connecting to Lightsail and deploying...$($NC)"

$remoteScript = @"
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

# Fix any broken package installations
echo "Cleaning up any broken installations..."
sudo dpkg --configure -a 2>/dev/null || true

# Kill any existing Node.js processes
echo "Stopping any running Node.js processes..."
pm2 delete feriwala-server 2>/dev/null || true
pkill -f "node" || true
sleep 2

# Check and install Node.js v20 if needed
if ! command -v node &> /dev/null || ! node -v | grep -q "v20"; then
    echo "Installing Node.js v20..."
    
    sudo apt-get remove -y nodejs npm 2>/dev/null || true
    sudo apt-get autoremove -y 2>/dev/null || true
    
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    
    for i in {1..3}; do
        if sudo apt-get install -y nodejs; then
            break
        elif [ $i -lt 3 ]; then
            echo "Installation attempt $i failed. Retrying..."
            sleep 5
        else
            echo "Failed to install Node.js"
            exit 1
        fi
    done
fi

echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# CRITICAL: Remove old node_modules completely to force rebuild
echo "Removing old node_modules for fresh rebuild..."
rm -rf $DEPLOY_PATH/server/node_modules

# Install server dependencies with correct Node version
# This ensures all native modules are built for Node v20
echo "Installing server dependencies with Node.js v20..."
cd $DEPLOY_PATH/server
npm install --production --verbose

# Create .env file
echo "Creating environment configuration..."
cat > .env << 'EOF'
MONGO_URL=mongodb+srv://ankush454563_db_user:Uufq8JEGONLwnj6S@cluster0.vwizt7t.mongodb.net/?appName=Cluster0
EMAIL_FOR_VERIFICATION=verify@feriwala.in
SMTP_SERVER=zoho.smtp.in
SMTP_PASSWORD=6u2Z05a0n5DnN7rL
NODE_ENV=production
PORT=3000
JWT_SECRET=your_jwt_secret_here
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

# Wait for app to start and verify
echo "Verifying application..."
sleep 5

# Check if process is still running
if pm2 status | grep -q "online"; then
    echo -e "\n=== Application is running! ==="
    pm2 status
else
    echo "ERROR: Application failed to start"
    echo "=== Error Logs ==="
    pm2 logs feriwala-server --lines 50
    exit 1
fi

# Configure nginx if not already done
echo "Configuring nginx..."
if ! grep -q "feriwala" /etc/nginx/sites-available/default 2>/dev/null; then
    sudo tee /etc/nginx/sites-available/default > /dev/null << 'NGINX_CONFIG'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    # Serve static client files
    location / {
        root /home/ubuntu/feriwala/client/dist;
        try_files $uri /index.html;
    }

    # Proxy API requests to Node.js server
    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Proxy WebSocket connections if any
    location /socket.io {
        proxy_pass http://localhost:3000/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'Upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX_CONFIG
    
    sudo systemctl restart nginx
    echo "Nginx configured and restarted"
else
    echo "Nginx already configured"
fi

echo -e "\n=== ${GREEN}Deployment Complete!${NC} ==="
echo "Application accessible at: http://13.127.193.200"
echo ""
echo "Useful commands:"
echo "  View logs: pm2 logs feriwala-server"
echo "  Restart: pm2 restart feriwala-server"
echo "  Status: pm2 status"
"@

# Execute the remote script via SSH
ssh -i "$DEPLOY_KEY" -o "StrictHostKeyChecking=no" "$DEPLOY_USER@$DEPLOY_HOST" "$remoteScript"

Write-Host "$($GREEN)[SUCCESS] Deployment completed!$($NC)"
Write-Host "Your application should now be running at: http://13.127.193.200"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  - Test the application: curl http://13.127.193.200"
Write-Host "  - View logs: ssh -i `"$DEPLOY_KEY`" $DEPLOY_USER@$DEPLOY_HOST `"`"pm2 logs feriwala-server`"`""
Write-Host "  - Restart app: ssh -i `"$DEPLOY_KEY`" $DEPLOY_USER@$DEPLOY_HOST `"`"pm2 restart feriwala-server`"`""
