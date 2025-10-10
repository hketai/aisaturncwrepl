# Production Deployment Guide - WhatsApp Web Integration

## 📋 Prerequisites

- Digital Ocean server (Ubuntu 20.04+)
- Node.js 18+ installed
- Ruby 3.2.2 with rbenv
- PostgreSQL and Redis running
- Nginx configured
- Existing Chatwoot installation at `/var/www/chatwoot`

## 🚀 WhatsApp Web Microservice Setup

### 1. Create Systemd Service

```bash
# Copy systemd service file to system directory
sudo cp /var/www/chatwoot/deployment/systemd/whatsapp-web.service /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable whatsapp-web

# Start the service
sudo systemctl start whatsapp-web

# Check service status
sudo systemctl status whatsapp-web
```

### 2. Environment Variables

Add to `/var/www/chatwoot/.env.production`:

```bash
# WhatsApp Web Security (REQUIRED)
WHATSAPP_WEB_SECRET=your-strong-secret-here

# WhatsApp Web Configuration
WHATSAPP_WEB_PORT=3001
RAILS_BASE_URL=https://app.aisaturn.co
```

**Generate secure secret:**
```bash
openssl rand -hex 32
```

### 3. Log Files Setup

```bash
# Create log directory if not exists
sudo mkdir -p /var/log/chatwoot

# Set proper permissions
sudo chown -R chatwoot:chatwoot /var/log/chatwoot

# View WhatsApp Web logs
sudo tail -f /var/log/chatwoot/whatsapp-web.log
sudo tail -f /var/log/chatwoot/whatsapp-web-error.log
```

### 4. Nginx Configuration (Optional)

If you want to proxy WhatsApp Web service through Nginx:

```nginx
# Add to your existing Nginx config
upstream whatsapp_web {
    server 127.0.0.1:3001 fail_timeout=0;
}

# Inside your server block
location /whatsapp-web/ {
    proxy_pass http://whatsapp_web/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Then reload Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Firewall Configuration

If using UFW:
```bash
# Allow WhatsApp Web port (if needed for direct access)
sudo ufw allow 3001/tcp
```

## 🔄 Restart Services

```bash
# Restart all services
sudo systemctl restart chatwoot-web
sudo systemctl restart chatwoot-worker
sudo systemctl restart whatsapp-web
sudo systemctl restart nginx
```

## 📊 Monitoring & Troubleshooting

### Check Service Status
```bash
sudo systemctl status whatsapp-web
```

### View Logs
```bash
# Real-time logs
sudo journalctl -u whatsapp-web -f

# Application logs
sudo tail -f /var/log/chatwoot/whatsapp-web.log
sudo tail -f /var/log/chatwoot/whatsapp-web-error.log
```

### Common Issues

**Service fails to start:**
```bash
# Check if dependencies are installed
cd /var/www/chatwoot/lib/whatsapp_web
npm install

# Check environment variables
cat /var/www/chatwoot/.env.production | grep WHATSAPP
```

**Port already in use:**
```bash
# Check what's using port 3001
sudo netstat -tulpn | grep 3001

# Kill process if needed
sudo kill -9 <PID>
```

## ✅ Verification

Test WhatsApp Web service:

```bash
# Health check
curl http://localhost:3001/health

# Expected response:
# {"status":"ok","timestamp":"2024-10-10T..."}
```

## 🔐 Security Checklist

- [ ] `WHATSAPP_WEB_SECRET` is set in `.env.production`
- [ ] Secret is at least 32 characters (generated with `openssl rand -hex 32`)
- [ ] Log files have proper permissions (owned by `chatwoot` user)
- [ ] Service is enabled to start on boot
- [ ] Firewall rules are configured properly

## 📝 GitHub Actions Integration

GitHub Actions workflow automatically:
1. Installs WhatsApp Web dependencies
2. Restarts the service on deployment

No manual intervention needed for deployments! Just push to `main` branch.

## 🆘 Support

For issues, check:
1. Service logs: `sudo journalctl -u whatsapp-web -f`
2. Application logs: `/var/log/chatwoot/whatsapp-web.log`
3. Nginx logs: `/var/log/nginx/error.log`
