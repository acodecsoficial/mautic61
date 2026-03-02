FROM php:8.2-apache-bookworm

ENV APACHE_DOCUMENT_ROOT=/var/www/html/docroot

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    cron \
    default-mysql-client \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxslt1-dev \
    libc-client2007e-dev \
    libkrb5-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mysqli \
        intl \
        zip \
        gd \
        mbstring \
        xml \
        xsl \
        opcache \
        imap \
    && a2enmod rewrite \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . /var/www/html

RUN rm -f composer.lock \
    && composer clear-cache \
    && COMPOSER_ALLOW_SUPERUSER=1 composer update --prefer-dist --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html \
    && mkdir -p /var/www/html/var /var/www/html/docroot/media \
    && chmod -R 775 /var/www/html/var /var/www/html/docroot/media

EXPOSE 80