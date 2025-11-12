# Feriwala

A simple e-commerce project with separate server and client apps.

## Local Development

### Prerequisites
- Node.js and npm installed
- Git installed

### Setup
1. Clone the repo:
   ```sh
   git clone https://github.com/ankush454575-sketch/feriwala.git
   cd feriwala
   ```
2. Install dependencies for both server and client:
   ```sh
   cd server
   npm install
   cd ../client
   npm install
   ```
3. Start the server and client (in separate terminals):
   ```sh
   # In server directory
   npm start
   # In client directory
   npm start
   ```

## Deployment via SSH (Lightsail)

1. Ensure your SSH key is present (not committed to the repo):
   - `LightsailDefaultKey-ap-south-1.pem` (should be in your local folder, not in the repo)
2. To deploy or run remote commands:
   ```sh
   ssh -i "c:/Users/ankud/Desktop/feriwala1.0/LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "ls -a"
   # Replace 'ls -a' with your deployment or setup command
   ```

## Security
- **Never commit private keys or secrets to the repository.**
- `.gitignore` is set up to exclude `.pem` files and other sensitive data.

## Project Structure
- `server/` - Backend code (Node.js/Express/TypeScript)
- `client/` - Frontend code (React/Vite)

---
For any issues, open an issue on GitHub or contact ankush454575@gmail.com.
