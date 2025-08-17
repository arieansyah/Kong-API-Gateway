# 🚀 Kong API Gateway - Production Deployment Guide

Panduan step-by-step untuk deploy Kong API Gateway di production environment dengan konfigurasi yang aman.

## 📋 Prerequisites

### System Requirements:

- **OS**: Ubuntu 20.04+ / CentOS 8+ / Docker-compatible Linux
- **RAM**: Minimal 4GB (recommended 8GB+)
- **CPU**: Minimal 2 cores (recommended 4+ cores)
- **Storage**: Minimal 20GB free space
- **Network**: Public IP dan domain name (untuk SSL)

### Software Requirements:

```bash
# Install Docker dan Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose v2
sudo apt update
sudo apt install docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

## 🎯 Deployment Steps

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git htop ufw

# Configure firewall
sudo ufw allow ssh
sudo ufw allow 3000/tcp    # Kong HTTP
sudo ufw allow 3001/tcp    # Kong HTTPS
sudo ufw --force enable

# Verify firewall
sudo ufw status
```

### Step 2: Clone dan Setup Project

```bash
# Clone repository
git clone <your-repo-url> kong-gateway
cd kong-gateway

# Verify file structure
ls -la
# Should see: docker-compose.production.yml, Makefile, etc.

# Make scripts executable
chmod +x init-db.sh
```

### Step 3: Environment Configuration

```bash
# Generate secure environment file
make setup

# Edit environment variables
nano .env

# Example secure .env:
DB_PASSWORD=$(openssl rand -base64 32)
KONG_ADMIN_PASSWORD=$(openssl rand -base64 24)
KONG_SESSION_SECRET=$(openssl rand -base64 64)
```

### Step 4: SSL Certificates Setup

#### Option A: Let's Encrypt (Recommended)

```bash
# Install certbot
sudo apt install -y certbot

# Stop any web server yang conflict
sudo systemctl stop nginx apache2 2>/dev/null

# Generate certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates
sudo mkdir -p ssl
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/kong.crt
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/kong.key
sudo chown $USER:$USER ssl/kong.*
```

#### Option B: Self-Signed (Testing Only)

```bash
# Create SSL directory
mkdir -p ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/kong.key \
  -out ssl/kong.crt \
  -subj "/C=ID/ST=Jakarta/L=Jakarta/O=Kong/CN=your-domain.com"

# Set proper permissions
chmod 600 ssl/kong.key
chmod 644 ssl/kong.crt
```

### Step 5: Production Deployment

```bash
# Run production readiness check
make prod-check

# Deploy Kong Gateway
make deploy

# Verify deployment
make status
make health
```

## 🔍 Post-Deployment Verification

### Step 1: Service Health Check

```bash
# Check all services status
make status

# Expected output:
# kong-database    running (healthy)
# kong-migration   exited (0)
# kong             running (healthy)

# Health verification
make health
```

### Step 2: Network Connectivity Test

```bash
# Test proxy endpoints
curl -I http://localhost:3000/status
# Expected: HTTP 200 OK

curl -I https://localhost:3001/status
# Expected: HTTP 200 OK (with SSL)

# Test admin endpoints (should fail from external)
curl -I http://your-server-ip:8001
# Expected: Connection refused atau timeout
```

### Step 3: Admin Access Setup

```bash
# From your local machine, create SSH tunnel
ssh -L 8002:127.0.0.1:8002 username@your-server-ip

# Or use make command on server
make admin-tunnel

# Open browser: http://localhost:8002
# Login with credentials dari .env file
```

## 🔧 Configuration

### Kong Service Configuration

```bash
# Access Kong Manager via SSH tunnel
# URL: http://localhost:8002

# Basic Kong service example via Admin API:
curl -X POST http://localhost:8001/services \
  --data "name=example-service" \
  --data "url=http://httpbin.org"

curl -X POST http://localhost:8001/services/example-service/routes \
  --data "hosts[]=example.com"
```

### Load Balancer Configuration

```nginx
# Example Nginx upstream untuk Kong
upstream kong_upstream {
    server 127.0.0.1:3000;
    # Add more Kong nodes untuk HA
    # server 127.0.0.1:3001;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://kong_upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 📊 Monitoring Setup

### Log Management

```bash
# Configure log rotation
sudo tee /etc/logrotate.d/kong << EOF
/var/lib/docker/containers/*/*-json.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF
```

### Health Monitoring Script

```bash
# Create monitoring script
cat > /usr/local/bin/kong-health-check.sh << 'EOF'
#!/bin/bash
cd /path/to/kong-gateway

# Health check
if ! make health > /dev/null 2>&1; then
    echo "Kong health check failed at $(date)" | logger -t kong-monitor
    # Send alert (email, Slack, etc.)
fi
EOF

chmod +x /usr/local/bin/kong-health-check.sh

# Add to crontab
echo "*/5 * * * * /usr/local/bin/kong-health-check.sh" | crontab -
```

## 🔄 Backup & Recovery

### Database Backup

```bash
# Create backup script
cat > backup-kong.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/kong"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup PostgreSQL database
docker compose -f docker-compose.production.yml exec -T kong-database \
  pg_dump -U kong kong > $BACKUP_DIR/kong-db-$DATE.sql

# Backup .env file
cp .env $BACKUP_DIR/env-$DATE.backup

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.backup" -mtime +30 -delete

echo "Backup completed: $DATE"
EOF

chmod +x backup-kong.sh

# Schedule daily backup
echo "0 2 * * * /path/to/kong-gateway/backup-kong.sh" | crontab -
```

### Recovery Procedure

```bash
# Stop services
make stop

# Restore database dari backup
docker compose -f docker-compose.production.yml up -d kong-database

# Wait untuk database ready
sleep 30

# Restore data
cat /backup/kong/kong-db-YYYYMMDD_HHMMSS.sql | \
  docker compose -f docker-compose.production.yml exec -T kong-database \
  psql -U kong kong

# Start semua services
make start
```

## 🚨 Troubleshooting

### Common Issues & Solutions

#### Issue 1: Kong tidak bisa connect ke database

```bash
# Check database logs
make logs-kong-database

# Common solution: restart database
docker compose -f docker-compose.production.yml restart kong-database

# Wait dan restart Kong
sleep 30
docker compose -f docker-compose.production.yml restart kong
```

#### Issue 2: SSL certificate errors

```bash
# Check certificate validity
openssl x509 -in ssl/kong.crt -text -noout

# Renew Let's Encrypt certificate
sudo certbot renew
sudo cp /etc/letsencrypt/live/your-domain.com/*.pem ssl/
make restart
```

#### Issue 3: Admin GUI tidak accessible

```bash
# Verify SSH tunnel
ssh -L 8002:127.0.0.1:8002 -v username@your-server

# Check Kong admin configuration
docker compose -f docker-compose.production.yml exec kong \
  kong config | grep -i admin
```

#### Issue 4: High memory usage

```bash
# Check resource usage
docker stats

# Adjust resource limits di docker-compose.production.yml
# Restart services
make restart
```

## 📈 Scaling & High Availability

### Horizontal Scaling

```bash
# Scale Kong instances
docker compose -f docker-compose.production.yml up -d --scale kong=3

# Use load balancer untuk distribute traffic
# Configure health checks di load balancer
```

### Database High Availability

```yaml
# Add PostgreSQL replication
services:
  kong-database-replica:
    image: postgres:13-alpine
    environment:
      POSTGRES_USER: kong
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: kong
    # Configure as read replica
```

## 🔐 Security Hardening

### Additional Security Measures

```bash
# Disable root login
sudo passwd -l root

# Setup fail2ban
sudo apt install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

### Security Monitoring

```bash
# Install intrusion detection
sudo apt install aide rkhunter chkrootkit

# Setup log monitoring
sudo apt install logwatch
```

## ✅ Production Checklist

### Pre-Go-Live:

- [ ] All services healthy dan running
- [ ] SSL certificates valid dan configured
- [ ] Firewall rules properly configured
- [ ] Admin access working via SSH tunnel
- [ ] Backup strategy implemented
- [ ] Monitoring dan alerting setup
- [ ] Load testing completed
- [ ] Security scan passed
- [ ] Documentation updated
- [ ] Team trained on operations

### Post-Go-Live:

- [ ] Monitor logs untuk errors
- [ ] Verify backup process
- [ ] Test disaster recovery procedure
- [ ] Monitor performance metrics
- [ ] Schedule regular maintenance
- [ ] Plan capacity expansion

---

## 🎉 Congratulations!

Kong API Gateway Anda sekarang running di production dengan konfigurasi yang aman dan scalable!

**Next Steps:**

1. Configure your APIs dan services
2. Setup monitoring dashboard
3. Implement CI/CD pipeline
4. Plan untuk regular maintenance

**Need Help?** Lihat troubleshooting section atau check logs dengan `make logs`
