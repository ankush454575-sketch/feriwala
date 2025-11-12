#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Step 1: Build the client and server ---
echo "Building the client..."
(cd client && npm install && npm run build)

echo "Building the server..."
(cd server && npm install && npm run build)

# --- Step 2: Package the application ---
echo "Packaging the application..."
rm -rf deploy
mkdir -p deploy/client/dist
mkdir -p deploy/server
cp -r client/dist/* deploy/client/dist/
cp server/package.json deploy/server/
cp server/package-lock.json deploy/server/
cp -r server/dist deploy/server/

tar -czf deploy.tar.gz -C deploy .

# --- Step 3: Upload to Lightsail ---
echo "Uploading to Lightsail..."
scp -i "LightsailDefaultKey-ap-south-1.pem" deploy.tar.gz ubuntu@13.127.193.200:~/

# --- Step 4: SSH and Deploy ---
echo "Connecting to Lightsail and deploying..."
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 <<'EOF'
  set -ex # Exit on error and print commands

  export PATH=$PATH:/usr/bin:/bin:/home/ubuntu/.nvm/versions/node/v18.20.3/bin

  # --- Clean up previous deployment ---
  echo "--- Cleaning up previous deployment ---"

  # Stop and delete all pm2 processes
  echo "Stopping and deleting all pm2 processes..."
  . ~/.nvm/nvm.sh && pm2 stop all || true
  . ~/.nvm/nvm.sh && pm2 delete all || true
  . ~/.nvm/nvm.sh && pm2 save --force || true
  
  # Remove nginx configuration
  echo "Removing nginx configuration..."
  sudo rm -f /etc/nginx/sites-enabled/feriwala
  sudo rm -f /etc/nginx/sites-available/feriwala
  sudo rm -f /etc/nginx/sites-enabled/default

  # Restart nginx to apply changes
  echo "Restarting nginx..."
  sudo systemctl restart nginx

  # Remove old application directory
  APP_DIR="feriwala"
  echo "Removing existing app directory..."
  rm -rf ~/$APP_DIR

  echo "--- Finished cleaning up ---"

  # --- Start new deployment ---
  echo "--- Starting new deployment ---"

  # Navigate to home directory
  cd ~

  # Check if archive exists
  if [ ! -f "deploy.tar.gz" ]; then
    echo "ERROR: deploy.tar.gz not found in home directory!"
    ls -la
    exit 1
  fi

  echo "Creating deployment directory..."
  mkdir -p ~/$APP_DIR

  echo "Extracting package..."
  tar -xzf deploy.tar.gz -C ~/$APP_DIR

  echo "Removing archive..."
  rm deploy.tar.gz

  echo "Installing dependencies..."
  sudo apt-get update
  sudo apt-get install -y nginx

  echo "Installing NVM and Node.js..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install 18
  nvm use 18
  nvm alias default 18

  # The following commands need to source nvm to use the correct node/npm version
  echo "Installing server dependencies..."
  cd ~/$APP_DIR/server
  . ~/.nvm/nvm.sh && npm install --production

  echo "Installing pm2..."
  . ~/.nvm/nvm.sh && npm install -g pm2

  echo "Starting server with pm2..."
  cd ~/$APP_DIR/server
  . ~/.nvm/nvm.sh && pm2 start dist/index.js --name feriwala-server

  echo "Configuring nginx..."
  sudo bash -c 'cat > /etc/nginx/sites-available/feriwala' <<'EOT'
server {
    listen 80;
    server_name 13.127.193.200;

    location / {
        root /home/ubuntu/feriwala/client/dist;
        try_files $uri /index.html;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOT
  sudo ln -s -f /etc/nginx/sites-available/feriwala /etc/nginx/sites-enabled/
  sudo systemctl restart nginx

  echo "Setting up pm2 to start on boot..."
  . ~/.nvm/nvm.sh
  
  # Get the full path to the pm2 executable
  PM2_PATH=$(which pm2)

  # The startup command needs to be run with sudo.
  # We pass the current PATH to sudo and add system paths to ensure systemctl is found.
  sudo env PATH=/usr/bin:/bin:$PATH $PM2_PATH startup systemd -u ubuntu --hp /home/ubuntu

  . ~/.nvm/nvm.sh && pm2 save

  echo "--- Deployment complete! ---"
EOF