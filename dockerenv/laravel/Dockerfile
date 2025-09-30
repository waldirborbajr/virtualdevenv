FROM php:7.4-cli

ARG USER_ID=1000
ARG GROUP_ID=1000

# Dependências Laravel + Firebird
RUN apt-get update && apt-get install -y \
    firebird-dev \
    libicu-dev \
    libzip-dev \
    unzip \
    git \
    libonig-dev \
    default-mysql-client \
    default-libmysqlclient-dev \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libgmp-dev \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*    

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions \
        pdo_firebird \
        pdo_mysql \
        intl \
        mbstring \
        bcmath \
        zip \
        gd \
        gmp \
        curl \
        dom \
        json \
        exif \
        pcntl  

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN groupadd -g ${GROUP_ID} www && useradd -u ${USER_ID} -g www -m www

WORKDIR /var/www/html
USER www

EXPOSE 8012
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8012"]

# Health check para verificar se o servidor está rodando
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8012 || exit 1
