# Feriwala Deployment Guide

## ✅ Status: LIVE AND RUNNING

**Application URL:** http://13.127.193.200

---

## Deployment Summary

Your Feriwala e-commerce application has been successfully deployed to AWS Lightsail with the following configuration:

### 🖥️ Infrastructure
- **Server**: AWS Lightsail (Ubuntu 22.04 LTS)
- **IP Address**: 13.127.193.200
- **SSH User**: ubuntu
- **SSH Key**: `LightsailDefaultKey-ap-south-1.pem`

### 📦 Technology Stack
- **Frontend**: React + Vite (served via nginx)
- **Backend**: Node.js v20.19.5 + Express
- **Database**: MongoDB Atlas (Cluster0)
- **Process Manager**: PM2 (with auto-restart)
- **Web Server**: nginx 1.18.0 (reverse proxy)
- **Email**: Zoho SMTP (verify@feriwala.in)

### 📁 Deployment Structure
```
/home/ubuntu/feriwala/
├── client/
│   └── dist/              # React build (served by nginx)
│       ├── index.html
│       ├── assets/
│       └── vite.svg
├── server/
│   ├── dist/              # TypeScript compiled code (run by PM2)
│   ├── node_modules/      # Dependencies (built for Node v20)
│   ├── package.json
│   └── .env              # Production environment variables
└── deploy.tar.gz         # Last deployment package
```

---

## Useful Commands

### Check Application Status
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "pm2 status"
```

### View Application Logs (Last 50 lines)
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "pm2 logs feriwala-server --lines 50"
```

### Real-time Log Streaming
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "pm2 logs feriwala-server"
```

### Restart Application
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "pm2 restart feriwala-server"
```

### Stop Application
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "pm2 stop feriwala-server"
```

### Start Application
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "pm2 start feriwala-server"
```

### SSH into Server
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200
```

---

## Deployment Scripts

Three deployment scripts have been created for different scenarios:

### `deploy-v4.sh` (Recommended - Latest)
- ✅ Proper Node.js v20 installation via NodeSource
- ✅ Rebuilds node_modules on server for correct native module versions
- ✅ Includes permission fixes
- ✅ Handles edge cases from previous deployments
- **Use this for production deployments**

### `deploy-v3.sh` (Alternative)
- ✅ Handles broken package installations
- ✅ Includes retry logic for robustness
- ✅ May need manual permission fixes after deployment

### `deploy-v2.sh` (Original)
- ⚠️ Early version with potential issues
- ✅ Basic deployment working but may encounter node_modules conflicts

### How to Deploy
```bash
cd C:\Users\ankud\Desktop\feriwala1.0
bash deploy-v4.sh
```

---

## Troubleshooting

### Application Returns 500 Error
**Symptoms**: HTTP 500 when accessing http://13.127.193.200

**Solution**:
```bash
# Check error logs
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "sudo tail -20 /var/log/nginx/error.log"

# If permission denied errors, fix permissions:
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "sudo chmod o+rx /home/ubuntu && sudo systemctl restart nginx"
```

### Application Crashes with Syntax Error
**Symptoms**: `SyntaxError: Unexpected token '?'` in MongoDB driver

**Cause**: Node.js version mismatch (node_modules built for different version)

**Solution**:
```bash
# SSH into server
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200

# Remove old node_modules
sudo rm -rf /home/ubuntu/feriwala/server/node_modules

# Reinstall dependencies
cd /home/ubuntu/feriwala/server
npm install --production

# Restart application
pm2 restart feriwala-server
```

### MongoDB Connection Fails
**Symptoms**: "Error connecting to MongoDB" in logs

**Solution**:
1. Verify MONGO_URL in `.env` on server is correct
2. Check MongoDB Atlas firewall allows AWS Lightsail IP (13.127.193.200)
3. Verify credentials in connection string

```bash
# Check .env on server
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "cat /home/ubuntu/feriwala/server/.env | grep MONGO"
```

### nginx Permission Denied Errors
**Symptoms**: `stat() failed (13: Permission denied)` in nginx error log

**Solution**:
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 << 'EOF'
# Allow www-data to access home directory
sudo chmod o+rx /home/ubuntu

# Ensure dist files are readable
sudo chmod -R 755 /home/ubuntu/feriwala/client/dist

# Restart nginx
sudo systemctl restart nginx
EOF
```

---

## Environment Variables

The application uses the following environment variables (set in `/home/ubuntu/feriwala/server/.env`):

```env
MONGO_URL=mongodb+srv://ankush454563_db_user:Uufq8JEGONLwnj6S@cluster0.vwizt7t.mongodb.net/?appName=Cluster0
EMAIL_FOR_VERIFICATION=verify@feriwala.in
SMTP_SERVER=zoho.smtp.in
SMTP_PASSWORD=6u2Z05a0n5DnN7rL
NODE_ENV=production
PORT=3000
```

### To Update Environment Variables
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 << 'EOF'
# Edit .env file
nano /home/ubuntu/feriwala/server/.env

# Restart application to apply changes
pm2 restart feriwala-server
EOF
```

---

## nginx Configuration

nginx is configured to:
1. Serve static files from `/home/ubuntu/feriwala/client/dist` on `/`
2. Proxy `/api/` requests to Node.js server on `localhost:3000`
3. Support WebSocket connections on `/socket.io`

**Configuration file**: `/etc/nginx/sites-available/default`

To update:
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "sudo nano /etc/nginx/sites-available/default"

# After editing, reload nginx:
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "sudo systemctl reload nginx"
```

---

## Auto-Restart on System Reboot

PM2 is configured to auto-start the application on system reboot via systemd:

```bash
# Verify PM2 startup service is enabled
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "systemctl is-enabled pm2-ubuntu"

# Should output: enabled
```

---

## Monitoring & Logs

### Real-time Application Monitoring
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 "watch pm2 monit"
```

### nginx Access Logs
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "sudo tail -f /var/log/nginx/access.log"
```

### nginx Error Logs
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "sudo tail -f /var/log/nginx/error.log"
```

### PM2 Configuration
```bash
ssh -i "LightsailDefaultKey-ap-south-1.pem" ubuntu@13.127.193.200 \
  "cat ~/.pm2/dump.pm2"
```

---

## GitHub Repository

**Repository**: https://github.com/ankush454575-sketch/feriwala

All deployment scripts have been committed and are available in the repository:
- `deploy-v2.sh` - Initial improved version
- `deploy-v3.sh` - Enhanced error recovery
- `deploy-v4.sh` - Final production version (recommended)

---

## Next Steps

1. **Test the application**: Visit http://13.127.193.200 in your browser
2. **Monitor logs**: Check PM2 logs regularly for any issues
3. **Set up monitoring**: Consider adding application monitoring tools
4. **Configure email**: Ensure Zoho SMTP credentials are working
5. **SSL/HTTPS**: Add SSL certificate (Let's Encrypt recommended)

---

## Important Notes

⚠️ **Security Reminders**:
- Keep SSH key (`LightsailDefaultKey-ap-south-1.pem`) secure
- Never commit `.env` files to version control (already in `.gitignore`)
- Use `.env` for sensitive data (never hardcode credentials)
- Consider adding firewall rules to restrict access if needed

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review PM2 logs for error messages
3. Verify environment variables are set correctly
4. Ensure MongoDB Atlas firewall allows your Lightsail IP

**Last Updated**: November 12, 2025
**Deployment Version**: 4 (Final)
