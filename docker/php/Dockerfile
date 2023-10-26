FROM php:8.2.10-fpm
COPY php.ini /usr/local/etc/php/
WORKDIR /var/www
RUN set -x \
    && apt-get update \
    && apt-get install -y libzip-dev git curl zip unzip vim default-mysql-client \
    && docker-php-ext-install pdo_mysql