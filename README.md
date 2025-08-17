# 🚀 Kong API Gateway Production Setup

Production-ready Kong API Gateway dengan PostgreSQL database, dikonfigurasi dengan keamanan tinggi dan akses admin yang aman melalui SSH tunneling.

## 📋 Fitur Utama

- ✅ **Kong 3.7** - API Gateway terbaru
- ✅ **PostgreSQL 13** - Database yang handal dengan konfigurasi keamanan
- ✅ **Kong Manager** - Web UI untuk administrasi Kong
- ✅ **Production Security** - Konfigurasi keamanan tingkat production
- ✅ **SSH Tunneling** - Akses admin yang aman tanpa expose ports
- ✅ **Health Checks** - Monitoring kesehatan semua services
- ✅ **Resource Limits** - Optimisasi penggunaan resource

## 🎯 Service URLs

### 🧪 Development Mode:

| Service                | URL                      | Akses         |
| ---------------------- | ------------------------ | ------------- |
| **Kong Proxy (HTTP)**  | `http://localhost:4000`  | Public        |
| **Kong Proxy (HTTPS)** | `https://localhost:4001` | Public        |
| **Kong Admin GUI**     | `http://localhost:9002`  | Direct Access |
| **Database**           | `localhost:5433`         | Direct Access |

### 🏭 Production Mode:

| Service                | URL                      | Akses          |
| ---------------------- | ------------------------ | -------------- |
| **Kong Proxy (HTTP)**  | `http://localhost:3000`  | Public         |
| **Kong Proxy (HTTPS)** | `https://localhost:3001` | Public         |
| **Kong Admin GUI**     | `http://localhost:8002`  | Via SSH Tunnel |

## 🚀 Quick Start

### 🧪 Development Environment (Recommended untuk Testing)

```bash
# Clone repository
git clone <repository-url>
cd Toen

# Quick development setup (one command!)
make dev

# Atau step by step:
make setup-dev    # Buat .env dengan development passwords
make start-dev    # Start development services

# Akses Kong Admin GUI (langsung accessible)
# Browser: http://localhost:8002
# Login: admin / admin123
```

### 🏭 Production Environment

```bash
# Setup dengan security yang ketat
make setup        # Generate secure passwords
nano .env         # Review password yang di-generate

# Deploy production
make deploy       # Atau: make start

# Akses admin secara aman via SSH tunnel
make admin-tunnel
# Browser: http://localhost:8002
```

## 📚 Perintah Management

```bash
# Lihat semua perintah yang tersedia
make help

# 🧪 Development commands (quick & easy)
make dev            # Quick start development (setup + start)
make setup-dev      # Setup development environment
make start-dev      # Start development services
make stop-dev       # Stop development services
make status-dev     # Status development containers
make health-dev     # Health check development
make logs-dev       # Logs development services
make clean-dev      # Cleanup development

# 🏭 Production commands (secure)
make setup          # Setup production dengan secure passwords
make start          # Start production services
make stop           # Stop production services
make restart        # Restart production services
make status         # Status production containers
make health         # Health check production
make logs           # Logs production services
make admin-tunnel   # SSH tunnel untuk admin access
make clean          # Cleanup production
make deploy         # Setup + start production

# 🔧 Utility commands
make prod-check     # Check production readiness
make clean-all      # Cleanup everything (dev + prod)
```

## 🔒 Keamanan

### Fitur Keamanan yang Diimplementasi:

1. **Admin Ports Protection** - Admin ports (8001, 8002) tidak di-expose ke public
2. **Basic Authentication** - Kong Admin GUI menggunakan basic auth
3. **Environment Variables** - Semua credentials menggunakan env vars
4. **Resource Limits** - CPU dan memory limits untuk setiap container
5. **Security Options** - no-new-privileges untuk container security
6. **Network Isolation** - Services berkomunikasi via internal network

### Cara Akses Admin yang Aman:

**❌ JANGAN**: Expose admin ports ke internet
**✅ GUNAKAN**: SSH tunneling untuk akses admin

```bash
# Dari server VPS
make admin-tunnel

# Atau manual SSH tunnel
ssh -L 8001:127.0.0.1:8001 -L 8002:127.0.0.1:8002 username@your-server-ip
```

## ⚙️ Konfigurasi

### 🧪 Development Environment (`.env`):

```bash
# Simple passwords untuk development
DB_PASSWORD=kong_dev_password
KONG_ADMIN_PASSWORD=admin123
KONG_SESSION_SECRET=dev_session_secret_change_in_production

# Akses Kong Admin: http://localhost:8002 (admin/admin123)
# Database: localhost:5432 (kong/kong_dev_password)
```

### 🏭 Production Environment (`.env`):

```bash
# Secure passwords untuk production (minimal 32-64 karakter)
DB_PASSWORD=your_very_secure_database_password_32chars_min
KONG_ADMIN_PASSWORD=your_very_secure_admin_password_32chars_min
KONG_SESSION_SECRET=your_very_long_session_secret_64chars_min
```

### Generate Secure Passwords untuk Production:

```bash
# Database password (32+ chars)
openssl rand -base64 32

# Session secret (64+ chars)
openssl rand -base64 64

# Atau gunakan make command
make setup    # Auto-generate semua passwords
```

## 📁 Struktur Project

```
Toen/
├── 📄 README.md                     # Dokumentasi utama
├── 🔒 SECURITY.md                   # Panduan keamanan
├── 🚀 DEPLOYMENT.md                 # Panduan deployment
├── 🐳 docker-compose.yml            # Development configuration
├── 🏭 docker-compose.production.yml # Production configuration
├── ⚙️  Makefile                     # Management commands
├── 📝 env.development.example       # Development environment template
├── 📝 env.production.example        # Production environment template
├── 🗂️ init-db.sh                   # Database initialization script
└── 🚫 .gitignore                   # Git ignore rules
```

## 🔍 Troubleshooting

### 🧪 Development Issues:

```bash
# Kong tidak bisa start (development)
make logs-dev-kong
make logs-dev-kong-database
make stop-dev && make start-dev

# Admin GUI tidak bisa diakses
# Browser: http://localhost:8002
# Login: admin / admin123
# Check: make status-dev

# Database connection error
make health-dev
make logs-dev-kong-database
docker compose restart kong-database
```

### 🏭 Production Issues:

```bash
# Kong tidak bisa start (production)
make logs-kong
make logs-kong-database
make restart

# Admin GUI tidak bisa diakses
make admin-tunnel
# Kemudian browser: http://localhost:8002

# Database connection error
make health
make logs-kong-database
docker compose -f docker-compose.production.yml restart kong-database
```

## 📊 Monitoring & Logs

### 🧪 Development Monitoring:

```bash
# Semua development services
make logs-dev

# Service tertentu (development)
make logs-dev-kong
make logs-dev-kong-database

# Health check development
make health-dev
make status-dev

# Direct access testing
curl http://localhost:3000/status  # Proxy
curl http://localhost:8002         # Admin GUI
```

### 🏭 Production Monitoring:

```bash
# Semua production services
make logs

# Service tertentu (production)
make logs-kong
make logs-kong-database

# Health check production
make health
make status

# Real-time dengan filter
docker compose -f docker-compose.production.yml logs -f kong | grep ERROR
```

## 🚧 Production Deployment

### Pre-deployment Checklist:

- [ ] Generate password yang kuat di `.env`
- [ ] Review konfigurasi firewall
- [ ] Setup SSL certificates di `./ssl/`
- [ ] Konfigurasi domain dan DNS
- [ ] Setup monitoring dan alerting
- [ ] Plan database backup strategy

### SSL Certificates:

```bash
# Buat directory SSL
mkdir -p ssl

# Option 1: Let's Encrypt (Production)
certbot certonly --standalone -d your-domain.com
cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/kong.crt
cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/kong.key

# Option 2: Self-signed (Testing)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/kong.key -out ssl/kong.crt
```

## 🆘 Support

### Logs untuk Debug:

```bash
# Kong dengan debug mode
docker compose -f docker-compose.production.yml exec kong kong config
docker compose -f docker-compose.production.yml logs -f kong

# Database connection test
docker compose -f docker-compose.production.yml exec kong-database psql -U kong -d kong -c "SELECT version();"
```

### Resource Monitoring:

```bash
# Check resource usage
docker stats

# Container info
docker compose -f docker-compose.production.yml ps
```

---

## 🎉 Selamat!

Kong API Gateway Anda sekarang sudah berjalan dengan konfigurasi production yang aman!

🔗 **Next Steps**:

- Konfigurasikan services/routes di Kong Manager
- Setup monitoring dan alerting
- Implement backup strategy
- Configure SSL certificates untuk domain Anda

📞 **Need Help?** Check troubleshooting section atau review logs dengan `make logs`

## 🔧 Solusi Port Conflicts - Update Manual

Anda perlu mengubah file `docker-compose.yml` untuk development dengan port range yang berbeda:

### 📝 Update `docker-compose.yml` (Development):

**Baris 18** - Database port:

```yaml
# DARI:
- "5432:5432"

# GANTI KE:
- "5433:5432" # Development database port
```

**Baris 67-68** - Admin URLs:

```yaml
# DARI:
KONG_ADMIN_GUI_URL: http://localhost:8002
KONG_ADMIN_API_URI: http://localhost:8001

# GANTI KE:
KONG_ADMIN_GUI_URL: http://localhost:9002
KONG_ADMIN_API_URI: http://localhost:9001
```

**Baris 84-89** - Ports mapping:

```yaml
# DARI:
ports:
  - "3000:3000" # HTTP proxy port
  - "3001:3001" # HTTPS proxy port
  - "8001:8001" # Admin API
  - "8002:8002" # Admin GUI

# GANTI KE:
ports:
  # Proxy ports (different from production)
  - "4000:3000" # HTTP proxy (dev: 4000, prod: 3000)
  - "4001:3001" # HTTPS proxy (dev: 4001, prod: 3001)
  # Admin ports (different from production)
  - "9001:8001" # Admin API (dev: 9001, prod: 8001)
  - "9002:8002" # Admin GUI (dev: 9002, prod: 8002)
```

### 📝 Update `Makefile` - Status Commands:

**Update bagian `status-dev`:**

```makefile
status-dev:
	@echo "📊 Development Service Status:"
	@docker compose ps
	@echo ""
	@echo "🌐 Development Service URLs:"
	@echo "  Kong Proxy (HTTP):   http://localhost:4000"
	@echo "  Kong Proxy (HTTPS):  https://localhost:4001"
	@echo "  Kong Admin GUI:      http://localhost:9002 (admin/admin123)"
	@echo "  Database:            localhost:5433 (kong/kong_dev_password)"
	@echo ""
	@echo "📝 Note: Development environment with direct admin access"
```

## ✅ Port Allocation Summary

| Service         | Development | Production       | Status             |
| --------------- | ----------- | ---------------- | ------------------ |
| **HTTP Proxy**  | `4000`      | `3000`           | ✅ **NO CONFLICT** |
| **HTTPS Proxy** | `4001`      | `3001`           | ✅ **NO CONFLICT** |
| **Admin API**   | `9001`      | `127.0.0.1:8001` | ✅ **NO CONFLICT** |
| **Admin GUI**   | `9002`      | `127.0.0.1:8002` | ✅ **NO CONFLICT** |
| **Database**    | `5433`      | Not exposed      | ✅ **NO CONFLICT** |

## 🚀 Usage Setelah Update

### 🧪 Development:

```bash
make dev
# Kong Proxy: http://localhost:4000
# Kong Admin: http://localhost:9002 (admin/admin123)
# Database: localhost:5433
```

### 🏭 Production:

```bash
make start
# Kong Proxy: http://localhost:3000
# Kong Admin: http://localhost:8002 (via SSH tunnel)
```

### 🔄 Bisa Jalan Bersamaan:

```bash
# Terminal 1 (Development)
make start-dev

# Terminal 2 (Production)
make start

# Keduanya bisa jalan tanpa conflict!
```

Apakah Anda ingin saya bantu dengan update file tertentu, atau Anda bisa langsung implement perubahan ini?
