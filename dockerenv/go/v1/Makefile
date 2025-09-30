# 5️⃣ Makefile unificado
.PHONY: dev build run deploy clean lint test vet

SERVICES := user-service order-service

dev:
	docker-compose up --build

build: lint vet test
	docker-compose build --no-cache

run: build
	docker-compose up -d

deploy: build
	@for svc in $(SERVICES); do \
	  echo "Push $$svc to registry:"; \
	  docker tag $$svc your_registry/$$svc:latest; \
	  docker push your_registry/$$svc:latest; \
	done

clean:
	docker-compose down --volumes --remove-orphans
	@for svc in $(SERVICES); do \
	  docker rmi -f $$svc || true; \
	done

lint:
	@echo "Running golint for all services..."
	@for svc in $(SERVICES); do \
	  cd $$svc && go install golang.org/x/lint/golint@latest && golint ./...; \
	  cd -; \
	done

vet:
	@echo "Running go vet for all services..."
	@for svc in $(SERVICES); do \
	  cd $$svc && go vet ./...; \
	  cd -; \
	done

test:
	@echo "Running tests for all services..."
	@for svc in $(SERVICES); do \
	  cd $$svc && go test ./... -cover; \
	  cd -; \
	done
