FROM node:20-alpine

WORKDIR /app

# Instalar dependências do sistema
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    bash

# Configurar npm para instalar pacotes globais sem sudo
RUN npm config set prefix /usr/local

# Instalar Yarn globalmente (usando método oficial)
RUN corepack enable && corepack prepare yarn@stable --activate

# Instalar Vue CLI globalmente com permissões corretas
RUN npm install -g @vue/cli @vue/cli-service-global --unsafe-perm

# Copiar arquivos de configuração e scripts
COPY entrypoint.sh /entrypoint.sh

# Tornar o entrypoint executável
RUN chmod +x /entrypoint.sh

# Expor porta para desenvolvimento
EXPOSE 8080

# Entrypoint que verifica se o projeto existe
ENTRYPOINT ["/entrypoint.sh"]

# Comando padrão
CMD ["yarn", "serve"]