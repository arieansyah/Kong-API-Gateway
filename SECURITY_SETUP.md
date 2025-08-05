# Security Setup Guide for Kong API Gateway

## 🔒 Perbaikan Keamanan yang Telah Diterapkan

### 1. **Environment Variables untuk Password**

- Password database dan Kong sekarang menggunakan environment variables
- Default password yang lebih kuat telah diset
- **PENTING**: Ganti semua password default sebelum deployment

### 2. **Database Security**

- Port database (5432) telah dihapus dari host exposure
- Database hanya bisa diakses dari internal network
- Password database menggunakan environment variable

### 3. **Kong Admin Security**

- Admin API dan GUI ports telah di-comment untuk keamanan
- Basic authentication ditambahkan untuk admin interface
- Session secret untuk keamanan tambahan

### 4. **Konga Security**

- Token dan JWT secrets ditambahkan
- Basic authentication untuk Konga dashboard
- Environment variables untuk semua credentials

## 🚀 Cara Setup yang Aman

### 1. **Setup Otomatis (Recommended)**

```bash
# Setup otomatis dengan password acak yang aman
make setup

# Atau untuk development
make dev-setup
```

### 2. **Setup Manual**

```bash
# Buat file .env dengan password yang kuat
cat > .env << EOF
# Database Security
POSTGRES_PASSWORD=your_very_secure_postgres_password_here_2024
KONG_PG_PASSWORD=your_very_secure_kong_password_here_2024

# Kong Admin Security
KONG_SESSION_SECRET=your_very_long_random_session_secret_here_2024
KONG_ADMIN_PASSWORD=your_very_secure_admin_password_here_2024

# Konga Security
KONGA_TOKEN_SECRET=your_very_long_random_konga_token_secret_here_2024
KONGA_JWT_SECRET=your_very_long_random_konga_jwt_secret_here_2024
KONGA_USER=admin
KONGA_PASSWORD=your_very_secure_konga_password_here_2024
KONGA_DB_ADAPTER=memory
EOF
```

### 3. **Generate Password yang Kuat**

```bash
# Generate random passwords
openssl rand -base64 24  # Untuk database password
openssl rand -base64 48  # Untuk session secrets
```

### 4. **Jalankan dengan Keamanan**

```bash
# Menggunakan Makefile (recommended)
make start

# Atau manual
docker-compose up -d

# Check status
make status
make health
```

## 🔐 Checklist Keamanan

- [ ] Ganti semua password default di file .env
- [ ] Gunakan password minimal 16 karakter
- [ ] Generate random secrets untuk session dan JWT
- [ ] Pastikan file .env tidak masuk ke version control
- [ ] Backup file .env dengan aman
- [ ] Monitor logs untuk aktivitas mencurigakan

## 📋 Akses Services

### Kong Proxy

- **HTTP**: http://localhost:8000 (standard Kong port)
- **HTTPS**: https://localhost:8443
- **Note**: Port 3000 diganti ke 8000 (standard Kong)

### Kong Admin (jika diaktifkan)

- **API**: http://localhost:8001 (hanya internal, tidak di-expose)
- **GUI**: http://localhost:8002 (hanya internal, tidak di-expose)
- **Credentials**: admin / [KONG_ADMIN_PASSWORD]

### Konga Dashboard

- **URL**: http://localhost:1337
- **Credentials**: [KONGA_USER] / [KONGA_PASSWORD]

### Management Commands

```bash
# Lihat semua commands yang tersedia
make help

# Check status semua services
make status

# Check health semua services
make health

# Lihat logs
make logs
```

## ⚠️ Peringatan Keamanan

1. **Jangan expose admin ports** ke internet tanpa VPN/firewall
2. **Gunakan HTTPS** untuk production
3. **Regular updates** untuk Docker images
4. **Monitor logs** untuk aktivitas mencurigakan
5. **Backup database** secara regular
6. **Rotate passwords** secara berkala

## 🛠️ Troubleshooting

### Jika Kong tidak bisa connect ke database:

```bash
# Check logs
docker-compose logs kong-database
docker-compose logs kong

# Restart services
docker-compose restart kong
```

### Jika Konga tidak bisa login:

```bash
# Check environment variables
docker-compose exec konga env | grep KONGA

# Restart Konga
docker-compose restart konga
```
