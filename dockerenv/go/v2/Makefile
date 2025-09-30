# 5️⃣ Makefile unificado
.PHONY: dev build run deploy clean purge lint test vet logs

SERVICES := user-service order-service

dev:
	docker-compose --env-file .env -f docker-compose.yaml -f docker-compose.override.yaml up --build

build: lint vet test
	docker-compose --env-file .env build --no-cache

run:
	docker-compose --env-file .env up -d

deploy: build
	@for svc in $(SERVICES); do \
	  echo "Push $$svc to registry:"; \
	  docker tag $$svc your_registry/$$svc:latest; \
	  docker push your_registry/$$svc:latest; \
	done

clean:
	docker-compose --env-file .env down --remove-orphans

purge: clean
	docker volume rm user_service_mariadb || true
	docker volume rm order_service_pg || true
	@for svc in $(SERVICES); do \
	  docker rmi -f $$svc || true; \
	done

lint:
	@set -e; \
	echo "Running golint for all services..."; \
	for svc in $(SERVICES); do \
	  cd $$svc && go install golang.org/x/lint/golint@latest && golint ./...; \
	  cd -; \
	done

vet:
	@set -e; \
	echo "Running go vet for all services..."; \
	for svc in $(SERVICES); do \
	  cd $$svc && go vet ./...; \
	  cd -; \
	done

test:
	@set -e; \
	echo "Running tests for all services..."; \
	for svc in $(SERVICES); do \
	  cd $$svc && go test ./... -cover; \
	  cd -; \
	done

logs:
	docker-compose --env-file .env logs -f
