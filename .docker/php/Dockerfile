ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-bookworm

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
        bcmath \
        ftp \
        gd \
        intl \
        opcache \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip \
        @composer

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
RUN groupmod -o -g "${GID}" www-data \
    && usermod -o -u "${UID}" -g "${GID}" www-data

ENV COMPOSER_HOME=/var/www/.composer
RUN mkdir -p /var/www/.composer \
    && chown -R www-data:www-data /var/www

WORKDIR /var/www/html