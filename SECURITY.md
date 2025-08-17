# 🔒 Security Guide - Kong API Gateway

Panduan keamanan lengkap untuk deployment Kong API Gateway di production environment.

## 🛡️ Security Overview

Setup ini mengimplementasi multiple layer security untuk melindungi Kong API Gateway:

- **Network Security**: Admin ports tidak di-expose ke public
- **Authentication**: Basic auth untuk Kong Admin GUI
- **Encryption**: Support SSL/TLS untuk traffic encryption
- **Container Security**: Non-root user dan security constraints
- **Access Control**: SSH tunneling untuk admin access

## 🚨 Critical Security Requirements

### ❌ NEVER DO THIS in Production:

```yaml
# JANGAN expose admin ports ke public
ports:
  - "8001:8001" # Admin API - BAHAYA!
  - "8002:8002" # Admin GUI - BAHAYA!
```

### ✅ ALWAYS DO THIS:

```yaml
# Hanya expose proxy ports
ports:
  - "3000:3000" # HTTP proxy (OK)
  - "3001:3001" # HTTPS proxy (OK)
  # Admin ports TIDAK di-expose
```

## 🔑 Password & Secrets Management

### Required Environment Variables:

```bash
# Database password (minimal 32 karakter)
DB_PASSWORD=very_long_secure_database_password_min_32_chars

# Kong admin password (minimal 32 karakter)
KONG_ADMIN_PASSWORD=very_long_secure_admin_password_min_32_chars

# Session secret (minimal 64 karakter untuk JWT signing)
KONG_SESSION_SECRET=very_long_session_secret_min_64_chars_for_jwt_signing
```

### Generate Secure Passwords:

```bash
# Generate database password
openssl rand -base64 32

# Generate session secret
openssl rand -base64 64

# Generate admin password
openssl rand -base64 24

# Atau menggunakan make command
make setup  # Auto-generate semua passwords
```

### Password Requirements:

- **Database Password**: 32+ karakter, alphanumeric + symbols
- **Admin Password**: 32+ karakter, strong complexity
- **Session Secret**: 64+ karakter, cryptographically secure random

## 🌐 Network Security

### Firewall Configuration:

```bash
# Allow hanya ports yang diperlukan
ufw allow 3000/tcp    # Kong HTTP proxy
ufw allow 3001/tcp    # Kong HTTPS proxy
ufw allow 22/tcp      # SSH untuk admin access
ufw deny 8001/tcp     # Block admin API
ufw deny 8002/tcp     # Block admin GUI
ufw enable
```

### Network Architecture:

```
Internet
    ↓
[Firewall/Load Balancer]
    ↓
Kong Proxy (3000/3001) ← Public Access
    ↓
Internal Network
    ↓
Kong Admin (8001/8002) ← SSH Tunnel Only
```

## 🔐 Admin Access Security

### SSH Tunneling (Recommended):

```bash
# Method 1: Using Makefile
make admin-tunnel

# Method 2: Manual SSH tunnel
ssh -L 8001:127.0.0.1:8001 -L 8002:127.0.0.1:8002 -N username@your-server

# Method 3: SSH with specific key
ssh -i ~/.ssh/kong-admin-key -L 8002:127.0.0.1:8002 username@your-server
```

### Access Flow:

1. **Establish SSH tunnel** ke server VPS
2. **Local browser** → `http://localhost:8002`
3. **Tunnel forwards** ke Kong Admin GUI di server
4. **Login** dengan credentials dari `.env`

### Admin Authentication:

```yaml
# Kong Admin GUI configuration
KONG_ADMIN_GUI_AUTH: basic-auth
KONG_ADMIN_GUI_AUTH_CONF: '{"admin": {"password": "${KONG_ADMIN_PASSWORD}"}}'
KONG_ADMIN_GUI_SESSION_SECRET: ${KONG_SESSION_SECRET}
```

## 🐳 Container Security

### Security Features Implemented:

```yaml
# Non-root user
user: kong

# Security options
security_opt:
  - no-new-privileges:true

# Resource limits
deploy:
  resources:
    limits:
      memory: 2G
      cpus: "2.0"
    reservations:
      memory: 1G
      cpus: "1.0"

# Secure tmpfs mounts
tmpfs:
  - /tmp
```

### Database Security:

```yaml
# Database tidak di-expose ke host
# Hanya accessible via internal network
networks:
  - kong-net

# Secure PostgreSQL configuration
command:
  - "postgres"
  - "-c"
  - "max_connections=200"
  - "-c"
  - "shared_preload_libraries=pg_stat_statements"
```

## 📋 Production Security Checklist

### Pre-Deployment:

- [ ] Generate strong passwords untuk semua services
- [ ] Configure firewall rules dengan benar
- [ ] Setup SSL certificates dari CA terpercaya
- [ ] Remove/disable development features
- [ ] Configure log level ke 'notice' atau 'warn'
- [ ] Enable security plugins (rate limiting, CORS, etc.)

### Post-Deployment:

- [ ] Verify admin ports tidak accessible dari internet
- [ ] Test SSH tunneling untuk admin access
- [ ] Configure monitoring dan alerting
- [ ] Setup log aggregation dan analysis
- [ ] Plan backup dan disaster recovery
- [ ] Schedule security updates

### Network Security Verification:

```bash
# Test dari external network
nmap -p 8001,8002 your-server-ip
# Should show: filtered atau closed

# Test proxy ports
curl -I http://your-server-ip:3000/status
# Should work

# Test admin access
curl -I http://your-server-ip:8001
# Should fail atau timeout
```

## 🚨 Incident Response

### If Admin Interface is Compromised:

1. **Immediate Actions**:

   ```bash
   # Block admin access immediately
   make stop

   # Change semua passwords
   nano .env  # Update semua credentials

   # Restart dengan new credentials
   make start
   ```

2. **Investigation**:

   ```bash
   # Review access logs
   make logs-kong | grep admin

   # Check for suspicious activities
   grep "8001\|8002" /var/log/nginx/access.log
   ```

3. **Recovery**:
   - Audit semua Kong configurations
   - Review dan reset API keys
   - Check semua services dan routes
   - Update security policies

### Emergency Shutdown:

```bash
# Quick shutdown semua services
make stop

# Or force stop with cleanup
docker compose -f docker-compose.production.yml down --remove-orphans
```

## 🔄 Security Maintenance

### Weekly Tasks:

- [ ] Review access logs untuk suspicious activities
- [ ] Check for Kong dan PostgreSQL updates
- [ ] Verify backup integrity
- [ ] Monitor resource usage

### Monthly Tasks:

- [ ] Rotate admin passwords
- [ ] Update container images
- [ ] Security vulnerability scan
- [ ] Review firewall rules

### Quarterly Tasks:

- [ ] Full security audit
- [ ] Penetration testing
- [ ] Disaster recovery test
- [ ] Update SSL certificates

## 📊 Security Monitoring

### Log Analysis:

```bash
# Monitor failed login attempts
make logs-kong | grep -i "unauthorized\|403\|401"

# Monitor admin access
make logs-kong | grep -i "admin"

# Monitor for errors
make logs-kong | grep -i "error\|fail"
```

### Security Metrics:

- Failed authentication attempts
- Admin API access patterns
- Unusual traffic patterns
- Resource usage anomalies
- Certificate expiration dates

## 🆘 Security Contacts

### Emergency Procedures:

1. **Isolate** affected systems immediately
2. **Document** the incident with timestamps
3. **Contact** security team/administrator
4. **Preserve** logs untuk investigation
5. **Follow** incident response playbook

---

## 📚 Additional Resources

- [Kong Security Best Practices](https://docs.konghq.com/gateway/latest/production/security/)
- [PostgreSQL Security](https://www.postgresql.org/docs/current/security.html)
- [Docker Security](https://docs.docker.com/engine/security/)

---

**Remember**: Security adalah ongoing process, bukan one-time setup. Selalu update dan monitor sistem Anda!
