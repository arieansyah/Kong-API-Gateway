# 🔒 Production Security Checklist untuk Kong Gateway

## ✅ Pre-Deployment Security Checklist

### 1. **Environment Variables & Secrets**

- [ ] Semua password default telah diganti dengan password yang kuat (min 32 karakter)
- [ ] Session secrets menggunakan cryptographically secure random values (min 64 karakter)
- [ ] File `.env` tidak di-commit ke version control
- [ ] Backup file `.env` disimpan di lokasi yang aman
- [ ] Password rotation policy sudah ditetapkan (recommended: 90 hari)

### 2. **Network Security**

- [ ] Admin ports (8001, 8002) TIDAK di-expose ke internet
- [ ] Hanya proxy ports (80, 443) yang accessible dari internet
- [ ] Firewall rules telah dikonfigurasi dengan benar
- [ ] SSL certificates valid dan dari CA terpercaya
- [ ] Trusted IPs dikonfigurasi sesuai infrastruktur

### 3. **Database Security**

- [ ] PostgreSQL menggunakan SCRAM-SHA-256 authentication
- [ ] Database port (5432) tidak di-expose ke host
- [ ] Database backup strategy sudah ditetapkan
- [ ] Database encryption at rest enabled (jika diperlukan)

### 4. **Kong Configuration**

- [ ] Log level diset ke 'notice' atau 'warn' (bukan 'debug')
- [ ] Rate limiting policies sudah dikonfigurasi
- [ ] Security plugins sudah enabled (CORS, JWT, Rate Limiting, etc.)
- [ ] Unnecessary plugins disabled

### 5. **Container Security**

- [ ] Running as non-root user
- [ ] Security options: no-new-privileges enabled
- [ ] Resource limits dikonfigurasi
- [ ] Base images menggunakan versi terbaru dan patch level
- [ ] Unnecessary packages tidak terinstall di container

### 6. **Monitoring & Logging**

- [ ] Centralized logging solution implemented
- [ ] Security monitoring alerts dikonfigurasi
- [ ] Health checks working properly
- [ ] Metrics collection enabled (Prometheus/Grafana)
- [ ] Log retention policy ditetapkan

## 🚨 Critical Security Actions

### Immediate Actions Required:

1. **Generate Secure Passwords:**

   ```bash
   # Database password (32+ chars)
   openssl rand -base64 48

   # Session secret (64+ chars)
   openssl rand -base64 64

   # Admin password (32+ chars)
   openssl rand -base64 48
   ```

2. **Remove Admin Port Exposure:**

   ```yaml
   # REMOVE these lines from docker-compose.yml in production:
   # - "8001:8001"
   # - "8002:8002"
   ```

3. **Access Admin Interface Securely:**

   ```bash
   # Use SSH tunnel instead:
   ssh -L 8001:localhost:8001 -L 8002:localhost:8002 your-server

   # Or use VPN/Bastion host
   ```

## 🛡️ Production Deployment Commands

### 1. Setup Production Environment:

```bash
# Copy example environment file
cp .env.production.example .env.production

# Edit with secure values
nano .env.production

# Validate configuration
docker-compose -f docker-compose.production.yml config
```

### 2. Deploy with Production Config:

```bash
# Deploy using production compose file
docker-compose -f docker-compose.production.yml --env-file .env.production up -d

# Verify deployment
docker-compose -f docker-compose.production.yml ps
docker-compose -f docker-compose.production.yml logs
```

### 3. SSL Certificates Setup:

```bash
# Create SSL directory
mkdir -p ssl

# Generate self-signed cert (for testing):
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/kong.key -out ssl/kong.crt

# Or use Let's Encrypt for production:
certbot certonly --standalone -d your-domain.com
cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/kong.crt
cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/kong.key
```

## 📊 Post-Deployment Verification

### Security Verification:

```bash
# Check that admin ports are not exposed
nmap -p 8001,8002 your-server-ip

# Verify SSL configuration
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Test authentication
curl -I https://your-domain.com:443/status
```

### Performance Verification:

```bash
# Check resource usage
docker stats

# Verify health checks
curl http://localhost/status
```

## 🔄 Maintenance Tasks

### Weekly:

- [ ] Review security logs
- [ ] Check for Kong updates
- [ ] Verify backup integrity

### Monthly:

- [ ] Security vulnerability scan
- [ ] Review access logs
- [ ] Update base images

### Quarterly:

- [ ] Rotate passwords and secrets
- [ ] Security audit
- [ ] Disaster recovery test

## 📞 Emergency Procedures

### If Compromised:

1. Immediately isolate affected systems
2. Change all passwords and secrets
3. Review access logs
4. Contact security team
5. Document incident

### Rollback Procedure:

```bash
# Quick rollback to previous version
docker-compose -f docker-compose.production.yml down
docker-compose -f docker-compose.production.yml up -d --scale kong=0
# Restore database from backup if needed
```

---

**Remember: Security is an ongoing process, not a one-time setup!**
