# Makefile for Vue.js + TypeScript + Tailwind + Axios Project

# Configuration
NIX_CMD := nix develop
PNPM := pnpm
NODE := node
NPM := npm

# Project info
PROJECT_NAME := vue-app
VERSION := 1.0.0

.PHONY: help dev build lint test install setup clean nix-shell nix-clean deps deps-upgrade

# Default target
help:
	@echo "Vue.js Project Makefile"
	@echo "========================"
	@echo ""
	@echo "Development:"
	@echo "  make dev       - Start development server"
	@echo "  make build     - Build for production"
	@echo "  make lint      - Run linter"
	@echo "  make test      - Run tests"
	@echo ""
	@echo "Dependencies:"
	@echo "  make install   - Install dependencies"
	@echo "  make deps      - Show outdated dependencies"
	@echo "  make deps-upgrade - Upgrade dependencies"
	@echo ""
	@echo "Project setup:"
	@echo "  make setup     - Setup Tailwind + Axios + Router"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make create    - Create new Vue project (usage: make create NAME=my-app)"
	@echo ""
	@echo "Nix environment:"
	@echo "  make nix-shell - Enter Nix development shell"
	@echo "  make nix-clean - Clean Nix cache"
	@echo ""
	@echo "Info:"
	@echo "  make info      - Show project info"
	@echo "  make help      - Show this help"

# Development commands
dev:
	@echo "🚀 Starting development server..."
	$(PNPM) dev

build:
	@echo "📦 Building for production..."
	$(PNPM) build

lint:
	@echo "🔍 Running linter..."
	$(PNPM) lint

test:
	@echo "🧪 Running tests..."
	$(PNPM) test

test-watch:
	@echo "🧪 Running tests in watch mode..."
	$(PNPM) test:watch

# Dependencies management
install:
	@echo "📥 Installing dependencies..."
	$(PNPM) install

deps:
	@echo "📊 Checking outdated dependencies..."
	$(PNPM) outdated

deps-upgrade:
	@echo "🔄 Upgrading dependencies..."
	$(PNPM) update

# Project setup
setup:
	@echo "⚙️ Setting up Tailwind CSS, Axios and Vue Router..."
	$(PNPM) add -D tailwindcss postcss autoprefixer @tailwindcss/forms
	npx tailwindcss init -p
	$(PNPM) add vue-router@4 axios
	@echo "✅ Setup complete! Don't forget to configure tailwind.config.js"

create:
ifndef NAME
	$(error Please specify project name: make create NAME=my-app)
endif
	@echo "🆕 Creating new Vue project: $(NAME)"
	$(PNPM) create vite $(NAME) --template vue-ts
	@echo "✅ Project created! cd $(NAME) && make install"

# Cleanup
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf dist
	rm -rf node_modules/.vite
	rm -rf coverage
	@echo "✅ Clean complete!"

clean-all: clean
	@echo "🧹 Cleaning all generated files..."
	rm -rf node_modules
	rm -f package-lock.json pnpm-lock.yaml yarn.lock
	rm -rf .DS_Store Thumbs.db

# Nix environment
nix-shell:
	@echo "🐚 Entering Nix development shell..."
	$(NIX_CMD)

nix-clean:
	@echo "🧹 Cleaning Nix cache..."
	nix-store --gc
	nix-store --optimise

# Project info
info:
	@echo "📊 Project Information"
	@echo "---------------------"
	@echo "Name: $(PROJECT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Node: $(shell node --version)"
	@echo "PNPM: $(shell pnpm --version)"
	@echo "Package manager: $(PNPM)"
	@echo ""
	@echo "Dependencies:"
	@$(PNPM) list --depth=0 2>/dev/null | grep -E "(vue|tailwind|axios|typescript|vite)" || echo "No dependencies found"

# Utility commands
serve:
	@echo "🌐 Serving built project..."
	$(PNPM) preview

audit:
	@echo "🔒 Auditing dependencies for vulnerabilities..."
	$(PNPM) audit

fix:
	@echo "🔧 Fixing linting issues..."
	$(PNPM) lint --fix

types-check:
	@echo "📝 Checking TypeScript types..."
	$(PNPM) type-check

# Docker-like commands for familiarity
up: dev
down:
	@pkill -f "vite" || true
	@echo "⏹️ Stopped development server"

logs:
	@echo "📋 Displaying recent logs..."
	@tail -f logs/*.log 2>/dev/null || echo "No log files found"

# Git helpers
git-status:
	@git status

git-commit:
	@git add .
	@git commit -m "$${MESSAGE:-Update}" || echo "Commit failed or no changes"

# Database simulation (if needed)
db-seed:
	@echo "🌱 Seeding database..."
	$(PNPM) exec tsx scripts/seed.ts || echo "No seed script found"

db-reset:
	@echo "🔄 Resetting database..."
	$(PNPM) exec tsx scripts/reset.ts || echo "No reset script found"

# Deployment
deploy-staging: build
	@echo "🚀 Deploying to staging..."
	# Add your deployment commands here

deploy-prod: build
	@echo "🚀 Deploying to production..."
	# Add your deployment commands here

# Backup
backup:
	@echo "💾 Creating backup..."
	tar -czf backup/$(shell date +%Y%m%d-%H%M%S).tar.gz src components assets

# Print environment
env:
	@echo "🌍 Environment:"
	@echo "NODE_ENV: $(NODE_ENV)"
	@echo "PATH: $(PATH)"
	@echo "NODE_PATH: $(NODE_PATH)"
