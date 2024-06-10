# Use the official PHP 8.1-FPM image as a base
FROM php:8.1-fpm

# Install system dependencies & clear cache
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libzip-dev \
    libonig-dev \
    zip \
    unzip \
    git \
    curl \
    gnupg \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

# Install additional PHP extension oniguruma
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libonig5 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Verify Node.js and npm installation
RUN node -v && npm -v

# Download and install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www

# Copy application files including Composer files and package files
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 9000
EXPOSE 9000

# Use entrypoint script
ENTRYPOINT ["entrypoint.sh"]

# Start php-fpm
CMD ["php-fpm"]