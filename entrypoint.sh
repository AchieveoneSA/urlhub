#!/bin/bash

# Install composer dependencies ignore platform reqs
composer install --ignore-platform-reqs --no-interaction

# Install Node.js dependencies
npm install

# Build assets
npm run prod

# Check if the .env file exists, if not, copy from .env.example and generate app key
if [ ! -f /var/www/.env ]; then
  cp /var/www/.env.example /var/www/.env
  php artisan key:generate
fi

# Clear config and cache
php artisan config:clear
php artisan cache:clear

# Run database migrations
php artisan migrate --force

# Run the main container command
exec "$@"
