# 2️⃣ Dockerfile para produção ultra enxuta (Dockerfile)
FROM golang:1.21 AS builder

WORKDIR /app
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Lint, vet, test
RUN go install golang.org/x/lint/golint@latest \
    && golint ./... \
    && go vet ./... \
    && go test ./... -cover

# Build otimizado + compressão UPX
RUN go build -ldflags="-s -w -extldflags '-static'" -o app ./... \
    && apt-get update && apt-get install -y upx \
    && upx --best ./app \
    && apt-get remove -y upx && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

FROM alpine:latest
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata mariadb-client postgresql-client

COPY --from=builder /app/app .

# Final do Dockerfile de produção
USER nobody

ENV LOG_LEVEL=info
EXPOSE 8080
CMD ["./app"]

