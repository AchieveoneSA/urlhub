# Stage 1: Composer
FROM composer:latest as composer
WORKDIR /urlhub
COPY composer.json composer.lock ./
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && \
    composer clear-cache
COPY . .
RUN composer dump-autoload --no-scripts --no-dev --optimize

# Install Node.js
FROM node:latest as node_base

# Stage 2: Nginx base
FROM nginx:latest as nginx_base
WORKDIR /var/www/urlhub
COPY --from=composer /urlhub /var/www/urlhub

# Install Node.js dependencies
RUN npm install

# Build assets
RUN npm run prod

# Stage 3: PHP-FPM
FROM php:8.2-fpm as php_fpm
WORKDIR /var/www/urlhub
COPY --from=composer /urlhub /var/www/urlhub
RUN apt-get update && apt-get install -y \
    libbz2-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libreadline-dev \
    sudo \
    zip \
 && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install \
    bcmath \
    bz2 \
    calendar \
    iconv \
    intl \
    mbstring \
    opcache \
    pdo_mysql \
    zip

# Stage 4: Nginx
FROM nginx_base as nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Stage 5: Final image combining PHP-FPM and Nginx
FROM php_fpm as final
COPY --from=nginx /etc/nginx /etc/nginx
