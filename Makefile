# Kong API Gateway Management (Development & Production)
.PHONY: help setup setup-dev start start-dev stop stop-dev restart logs clean health status admin-tunnel dev

# Default target
help:
	@echo "Kong API Gateway Management Commands:"
	@echo ""
	@echo "🚀 Development Commands:"
	@echo "  dev          - Quick start development environment"
	@echo "  setup-dev    - Create .env file for development"
	@echo "  start-dev    - Start development services"
	@echo "  stop-dev     - Stop development services"
	@echo ""
	@echo "🏭 Production Commands:"
	@echo "  setup        - Create .env file with secure defaults"
	@echo "  start        - Start all services (production mode)"
	@echo "  stop         - Stop all services"
	@echo "  restart      - Restart all services"
	@echo "  admin-tunnel - Create SSH tunnel for admin access"
	@echo ""
	@echo "📊 Monitoring Commands:"
	@echo "  logs         - Show logs for all services"
	@echo "  health       - Check health status of all services"
	@echo "  status       - Show running containers"
	@echo "  clean        - Stop and remove all containers and volumes"
	@echo ""
	@echo "🌐 Service URLs:"
	@echo "  Kong Proxy (HTTP):   http://localhost:3000"
	@echo "  Kong Proxy (HTTPS):  https://localhost:3001"
	@echo "  Kong Admin GUI (dev): http://localhost:8002 (development)"
	@echo "  Kong Admin GUI (prod): http://localhost:8002 (via SSH tunnel)"

# Create .env file for development
setup-dev:
	@if [ ! -f .env ]; then \
		echo "Creating .env file for development..."; \
		cp env.development.example .env; \
		echo "✅ Development .env file created successfully!"; \
		echo "📝 Admin GUI: http://localhost:8002 (username: admin, password: admin123)"; \
		echo "⚠️  Development passwords - NOT for production!"; \
	else \
		echo "❌ .env file already exists. Delete it first if you want to regenerate."; \
	fi

# Create .env file with secure defaults for production
setup:
	@if [ ! -f .env ]; then \
		echo "Creating .env file with secure defaults..."; \
		echo "# Kong API Gateway Production Environment Variables" > .env; \
		echo "# Generated on $$(date)" >> .env; \
		echo "" >> .env; \
		echo "# Database Configuration" >> .env; \
		echo "DB_PASSWORD=$$(openssl rand -base64 32)" >> .env; \
		echo "" >> .env; \
		echo "# Kong Security Configuration" >> .env; \
		echo "KONG_SESSION_SECRET=$$(openssl rand -base64 64)" >> .env; \
		echo "KONG_ADMIN_PASSWORD=$$(openssl rand -base64 24)" >> .env; \
		echo "" >> .env; \
		echo "✅ .env file created successfully!"; \
		echo "⚠️  Please review and customize the values in .env file"; \
		echo "🔐 Admin GUI: Use SSH tunnel to access http://localhost:8002"; \
		echo "📝 Run 'make admin-tunnel' to create secure tunnel"; \
	else \
		echo "❌ .env file already exists. Delete it first if you want to regenerate."; \
	fi

# Quick development setup
dev: setup-dev start-dev
	@echo "🚀 Development environment ready!"
	@echo "🌐 Kong Admin GUI: http://localhost:8002"
	@echo "🔑 Login: admin / admin123"

# Start development services
start-dev:
	@echo "🚀 Starting Kong API Gateway (Development Mode)..."
	@docker compose up -d
	@echo "✅ Development services started successfully!"
	@echo ""
	@make status-dev

# Start all services in production mode
start:
	@echo "🚀 Starting Kong API Gateway (Production Mode)..."
	@docker compose -f docker-compose.production.yml up -d
	@echo "✅ Services started successfully!"
	@echo ""
	@make status

# Stop development services
stop-dev:
	@echo "🛑 Stopping Kong API Gateway (Development)..."
	@docker compose down
	@echo "✅ Development services stopped successfully!"

# Stop production services
stop:
	@echo "🛑 Stopping Kong API Gateway (Production)..."
	@docker compose -f docker-compose.production.yml down
	@echo "✅ Production services stopped successfully!"

# Restart all services
restart:
	@echo "🔄 Restarting Kong API Gateway..."
	@docker compose -f docker-compose.production.yml restart
	@echo "✅ Services restarted successfully!"

# Show logs for development
logs-dev:
	@docker compose logs -f

# Show logs for production
logs:
	@docker compose -f docker-compose.production.yml logs -f

# Show logs for specific service (development)
logs-dev-%:
	@docker compose logs -f $*

# Show logs for specific service (production)
logs-%:
	@docker compose -f docker-compose.production.yml logs -f $*

# Check development health status
health-dev:
	@echo "🔍 Checking development service health..."
	@echo ""
	@echo "📊 Container Status:"
	@docker compose ps
	@echo ""
	@echo "🏥 Health Checks:"
	@docker compose exec kong kong health 2>/dev/null && echo "✅ Kong: Healthy" || echo "❌ Kong: Unhealthy"
	@docker compose exec kong-database pg_isready -U kong 2>/dev/null && echo "✅ Database: Healthy" || echo "❌ Database: Unhealthy"
	@curl -s -f http://localhost:3000/status >/dev/null 2>&1 && echo "✅ Kong Proxy: Healthy" || echo "❌ Kong Proxy: Unhealthy"
	@curl -s -f http://localhost:8002 >/dev/null 2>&1 && echo "✅ Kong Admin GUI: Healthy" || echo "❌ Kong Admin GUI: Unhealthy"

# Check production health status  
health:
	@echo "🔍 Checking production service health..."
	@echo ""
	@echo "📊 Container Status:"
	@docker compose -f docker-compose.production.yml ps
	@echo ""
	@echo "🏥 Health Checks:"
	@docker compose -f docker-compose.production.yml exec kong kong health 2>/dev/null && echo "✅ Kong: Healthy" || echo "❌ Kong: Unhealthy"
	@docker compose -f docker-compose.production.yml exec kong-database pg_isready -U kong 2>/dev/null && echo "✅ Database: Healthy" || echo "❌ Database: Unhealthy"
	@curl -s -f http://localhost:3000/status >/dev/null 2>&1 && echo "✅ Kong Proxy: Healthy" || echo "❌ Kong Proxy: Unhealthy"

# Show development containers status
status-dev:
	@echo "📊 Development Service Status:"
	@docker compose ps
	@echo ""
	@echo "🌐 Development Service URLs:"
	@echo "  Kong Proxy (HTTP):   http://localhost:3000"
	@echo "  Kong Proxy (HTTPS):  https://localhost:3001"
	@echo "  Kong Admin GUI:      http://localhost:8002 (admin/admin123)"
	@echo "  Database:            localhost:5432 (kong/kong_dev_password)"
	@echo ""
	@echo "📝 Note: Development environment with direct admin access"

# Show production containers status
status:
	@echo "📊 Production Service Status:"
	@docker compose -f docker-compose.production.yml ps
	@echo ""
	@echo "🌐 Production Service URLs:"
	@echo "  Kong Proxy (HTTP):  http://localhost:3000"
	@echo "  Kong Proxy (HTTPS): https://localhost:3001"
	@echo "  Kong Admin (tunnel): http://localhost:8002 (via SSH tunnel)"
	@echo ""
	@echo "📝 Note: Run 'make admin-tunnel' to access Kong Admin GUI securely"

# Clean up development environment
clean-dev:
	@echo "🧹 Cleaning up Kong API Gateway (Development)..."
	@docker compose down -v --remove-orphans
	@echo "✅ Development cleanup completed!"

# Clean up production environment
clean:
	@echo "🧹 Cleaning up Kong API Gateway (Production)..."
	@docker compose -f docker-compose.production.yml down -v --remove-orphans
	@echo "✅ Production cleanup completed!"

# Clean up everything (both dev and prod)
clean-all: clean-dev clean
	@docker system prune -f
	@echo "✅ Complete cleanup finished!"

# Create secure SSH tunnel for admin access
admin-tunnel:
	@echo "🔐 Creating secure tunnel for Kong Admin GUI..."
	@echo "Access Kong Manager at: http://localhost:8002"
	@echo "Press Ctrl+C to close tunnel"
	@echo ""
	@ssh -L 8001:127.0.0.1:8001 -L 8002:127.0.0.1:8002 -N localhost

# Production deployment check
prod-check:
	@echo "🔍 Production readiness check..."
	@echo ""
	@if [ ! -f .env ]; then \
		echo "❌ .env file missing - run 'make setup' first"; \
		exit 1; \
	fi
	@echo "✅ .env file exists"
	@if grep -q "CHANGE_THIS" .env; then \
		echo "⚠️  Warning: Default values found in .env file"; \
		echo "   Please update with secure values before production deployment"; \
	else \
		echo "✅ .env file appears to have custom values"; \
	fi
	@echo "✅ Production readiness check completed"

# Quick deployment (setup + start)
deploy: setup start
	@echo "🚀 Kong API Gateway deployed successfully!"
	@make status