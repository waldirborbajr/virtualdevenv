# Define project name
PROJECT_NAME_DEV=omniapidev
PROJECT_NAME_PROD=omniapiprod

# Mark targets as phony (not file-based)
.PHONY: up down restart logs artisan composer route install tinker migrate bash prune inspect build-prod push-prod deploy-prod down-prod logs-prod inspect-prod

# ===============================
# Configurações da rede macvlan
# ===============================
HOST_IFACE ?= enp3s0f0          # Interface física do host (ex: eth0, enp3s0f0, ens33)
HOST_MACVLAN_IP ?= 192.168.0.19 # IP livre na rede para o host falar com containers
HOST_NETMASK ?= 24              # Máscara da rede (geralmente /24)
CONTAINER_IP ?= 192.168.0.17    # IP fixo do container na rede macvlan
CONTAINER_PORT ?= 8012          # Porta exposta pelo serviço Laravel

# ===============================
# Alvos principais
# ===============================

up: macvlan-up
	@echo "🔄 Subindo containers..."
	docker compose up --build --force-recreate
#	$(MAKE) test-net

down:
	@echo "🛑 Parando containers..."
	docker compose down --rmi all --remove-orphans

restart: down up

logs:
	docker compose logs -f $(PROJECT_NAME_DEV)

bash:
	docker compose exec -it $(PROJECT_NAME_DEV) bash

ps:
	docker compose ps

artisan:
	docker compose exec $(PROJECT_NAME_DEV) php artisan $(cmd)

route:
	docker compose exec $(PROJECT_NAME_DEV) php artisan route:list

route-clear:
	docker compose exec $(PROJECT_NAME_DEV) php artisan route:clear
	docker compose exec $(PROJECT_NAME_DEV) php artisan config:clear

# ===============================
# Rede host <-> macvlan
# ===============================

macvlan-up:
	@echo "🌐 Verificando interface macvlan0 no host..."
	@if ip link show macvlan0 >/dev/null 2>&1; then \
		echo "✔️ Interface macvlan0 já existe."; \
	else \
		sudo ip link add macvlan0 link $(HOST_IFACE) type macvlan mode bridge && \
		sudo ip addr add $(strip $(HOST_MACVLAN_IP))/$(strip $(HOST_NETMASK)) dev macvlan0 && \
		sudo ip link set macvlan0 up && \
		echo "✅ Interface macvlan0 criada com IP $(HOST_MACVLAN_ADDR)."; \
	fi

macvlan-down:
	@if ip link show macvlan0 >/dev/null 2>&1; then \
		sudo ip link set macvlan0 down && \
		sudo ip addr del $(strip $(HOST_MACVLAN_IP))/$(strip $(HOST_NETMASK)) dev macvlan0 &&არ

# ===============================
# Testes de conectividade
# ===============================

test-net:
	@echo "📡 Testando conectividade com o container em $(CONTAINER_IP)..."
	@if ping -c 2 $(CONTAINER_IP) >/dev/null 2>&1; then \
		echo "✅ Conectividade OK: host alcança o container $(CONTAINER_IP)."; \
	else \
		echo "❌ Erro: host não consegue alcançar o container $(CONTAINER_IP)."; \
	fi
	@echo "🔍 Verificando se o serviço Laravel responde na porta $(CONTAINER_PORT)..."
	@if curl -s -o /dev/null -w "%{http_code}" http://$(CONTAINER_IP):$(CONTAINER_PORT) | grep -q "200"; then \
		echo "✅ Serviço Laravel responde em http://$(CONTAINER_IP):$(CONTAINER_PORT)"; \
	else \
		echo "⚠️ Aviso: serviço Laravel não respondeu na porta $(CONTAINER_PORT)."; \
	fi

prune:
	docker compose down -v --rmi all || true
	docker network rm omni-api-master_laravel-network || true
	docker system prune -af --volumes

inspect:
	docker inspect omniapi --format='{{.State.Health.Status}}'

# ===============================
# Alvos para produção
# ===============================

build-prod:
	@echo "🛠️ Construindo imagem de produção..."
	docker build -f Dockerfile.prod -t ${PROJECT_NAME_PROD}:prod .

push-prod:
	@echo "🚀 Enviando imagem para registry..."
	# Replace 'your-registry' with your actual registry (e.g., Docker Hub, AWS ECR)
	docker tag ${PROJECT_NAME_PROD}:prod your-registry/${PROJECT_NAME_PROD}:prod
	docker push your-registry/${PROJECT_NAME_PROD}:prod

deploy-prod:
	@echo "🚀 Deployando container de produção..."
	@export APP_KEY=base64:KJE7L0kKY+aPQpPNeCuRse2Ckc2cxpUXDm8csivsHD0=; \
	export DB_PASSWORD_PA=@senha; \
	export DB_PASSWORD_KBB=@senha; \
	export DB_PASSWORD=masterkey; \
	export MAIL_PASSWORD="#Senha_123_Mudar*"; \
	docker compose -f docker-compose.prod.yaml up -d

down-prod:
	@echo "🛑 Parando container de produção..."
	docker compose -f docker-compose.prod.yaml down

logs-prod:
	docker compose -f docker-compose.prod.yaml logs -f

inspect-prod:
	docker inspect omniapi-prod --format='{{.State.Health.Status}}'
