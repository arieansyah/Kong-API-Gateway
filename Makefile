# Kong API Gateway Management
.PHONY: help setup start stop restart logs clean health status

# Default target
help:
	@echo "Kong API Gateway Management Commands:"
	@echo ""
	@echo "  setup     - Create .env file with secure defaults"
	@echo "  start     - Start all services"
	@echo "  stop      - Stop all services"
	@echo "  restart   - Restart all services"
	@echo "  logs      - Show logs for all services"
	@echo "  health    - Check health status of all services"
	@echo "  status    - Show running containers"
	@echo "  clean     - Stop and remove all containers and volumes"
	@echo ""
	@echo "Service URLs:"
	@echo "  Kong Proxy:     http://localhost:8000"
	@echo "  Kong SSL Proxy: https://localhost:8443"
	@echo "  Konga Dashboard: http://localhost:1337"

# Create .env file with secure defaults
setup:
	@if [ ! -f .env ]; then \
		echo "Creating .env file with secure defaults..."; \
		echo "# Kong API Gateway Environment Variables" > .env; \
		echo "# Generated on $$(date)" >> .env; \
		echo "" >> .env; \
		echo "# Database Configuration" >> .env; \
		echo "DB_PASSWORD=$$(openssl rand -base64 24)" >> .env; \
		echo "" >> .env; \
		echo "# Kong Security Configuration" >> .env; \
		echo "KONG_SESSION_SECRET=$$(openssl rand -base64 48)" >> .env; \
		echo "KONG_ADMIN_PASSWORD=$$(openssl rand -base64 16)" >> .env; \
		echo "" >> .env; \
		echo "# Konga Configuration" >> .env; \
		echo "KONGA_TOKEN_SECRET=$$(openssl rand -base64 48)" >> .env; \
		echo "KONGA_JWT_SECRET=$$(openssl rand -base64 48)" >> .env; \
		echo "# Note: Konga will create its own user database" >> .env; \
		echo ""; \
		echo "✅ .env file created successfully!"; \
		echo "⚠️  Please review and customize the values in .env file"; \
		echo "📝 Konga: Access at http://localhost:1337 and create your admin user"; \
	else \
		echo "❌ .env file already exists. Delete it first if you want to regenerate."; \
	fi

# Start all services
start:
	@echo "🚀 Starting Kong API Gateway..."
	@docker compose up -d
	@echo "✅ Services started successfully!"
	@echo ""
	@make status

# Stop all services
stop:
	@echo "🛑 Stopping Kong API Gateway..."
	@docker compose down
	@echo "✅ Services stopped successfully!"

# Restart all services
restart:
	@echo "🔄 Restarting Kong API Gateway..."
	@docker compose restart
	@echo "✅ Services restarted successfully!"

# Show logs for all services
logs:
	@docker compose logs -f

# Show logs for specific service
logs-%:
	@docker compose logs -f $*

# Check health status
health:
	@echo "🔍 Checking service health..."
	@echo ""
	@echo "📊 Container Status:"
	@docker compose ps
	@echo ""
	@echo "🏥 Health Checks:"
	@docker compose exec kong kong health 2>/dev/null && echo "✅ Kong: Healthy" || echo "❌ Kong: Unhealthy"
	@curl -s -f http://localhost:1337 >/dev/null 2>&1 && echo "✅ Konga: Healthy" || echo "❌ Konga: Unhealthy"
	@docker compose exec kong-database pg_isready -U kong 2>/dev/null && echo "✅ Database: Healthy" || echo "❌ Database: Unhealthy"

# Show running containers
status:
	@echo "📊 Service Status:"
	@docker compose ps
	@echo ""
	@echo "🌐 Service URLs:"
	@echo "  Kong Proxy:      http://localhost:8000"
	@echo "  Kong SSL Proxy:  https://localhost:8443"
	@echo "  Konga Dashboard: http://localhost:1337"
	@echo ""
	@echo "📝 Note: Run 'make setup' first to create environment variables"

# Clean up everything
clean:
	@echo "🧹 Cleaning up Kong API Gateway..."
	@docker compose down -v --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup completed!"

# Development helpers
dev-setup: setup start
	@echo "🚀 Development environment ready!"

# Production deployment check
prod-check:
	@echo "🔍 Production readiness check..."
	@echo ""
	@if [ ! -f .env ]; then \
		echo "❌ .env file missing"; \
		exit 1; \
	fi
	@echo "✅ .env file exists"
	@if grep -q "your_" .env; then \
		echo "⚠️  Warning: Default values found in .env file"; \
		echo "   Please update with secure values before production deployment"; \
	else \
		echo "✅ .env file appears to have custom values"; \
	fi
	@echo "✅ Production readiness check completed"