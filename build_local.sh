#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Building the client ---"
(cd client && npm install && npm run build)

echo "--- Building the server ---"
(cd server && npm install && npm run build)

echo "--- Packaging the application ---"
rm -rf deploy
mkdir -p deploy/client/dist
mkdir -p deploy/server
cp -r client/dist/* deploy/client/dist/
cp server/package.json deploy/server/
cp server/package-lock.json deploy/server/
cp -r server/dist deploy/server/

tar -czf deploy.tar.gz -C deploy .

echo "--- Local build and packaging complete ---"
echo "The deployment package 'deploy.tar.gz' has been created."
echo "You can now ask me to upload and deploy this package to your Lightsail instance."
