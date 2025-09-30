.PHONY: up down build logs shell clean install status help ps debug

# Variáveis
DOCKER_COMPOSE = docker compose
CONTAINER_NAME = vue-dev

# Iniciar o ambiente
up:
	@echo "🚀 Iniciando ambiente de desenvolvimento Vue.js..."
	$(DOCKER_COMPOSE) up -d --build
	@echo "⏳ Aguardando inicialização..."
	@sleep 5
	@make logs

# Parar o ambiente
down:
	@echo "🛑 Parando ambiente..."
	$(DOCKER_COMPOSE) down

# Build da imagem
build:
	@echo "🔨 Construindo imagem Docker..."
	$(DOCKER_COMPOSE) build

# Ver logs do container
logs:
	@echo "📋 Mostrando logs..."
	$(DOCKER_COMPOSE) logs -f

# Acessar shell do container
shell:
	@echo "💻 Acessando shell do container..."
	docker exec -it $(CONTAINER_NAME) /bin/sh

# Debug - Executar container interativo
debug:
	@echo "🐛 Modo debug - Container interativo..."
	docker run -it --rm -v $(PWD):/app -w /app node:20-alpine /bin/sh

# Limpar ambiente
clean:
	@echo "🧹 Limpando ambiente..."
	$(DOCKER_COMPOSE) down -v
	docker system prune -f
	rm -rf node_modules package.json vite.config.js index.html src

# Instalar dependências
install:
	@echo "📦 Instalando dependências..."
	docker exec -it $(CONTAINER_NAME) yarn install

# Status dos containers Docker (todos, não apenas do compose)
ps:
	@echo "📊 Containers em execução:"
	docker ps

# Status dos containers do compose
status:
	@echo "📊 Status dos containers:"
	$(DOCKER_COMPOSE) ps

# Help
help:
	@echo "Comandos disponíveis:"
	@echo "  make up        - Iniciar ambiente e criar projeto Vue"
	@echo "  make down      - Parar ambiente"
	@echo "  make build     - Construir imagem Docker"
	@echo "  make logs      - Ver logs do container"
	@echo "  make shell     - Acessar shell do container"
	@echo "  make debug     - Container interativo para debug"
	@echo "  make clean     - Limpar ambiente completamente"
	@echo "  make install   - Instalar dependências"
	@echo "  make ps        - Ver todos containers Docker"
	@echo "  make status    - Ver status containers compose"
	@echo "  make help      - Mostrar esta ajuda"

# Forçar recriação
force-recreate:
	@echo "🔄 Forçando recriação do container..."
	$(DOCKER_COMPOSE) up -d --force-recreate --build
	@make logs