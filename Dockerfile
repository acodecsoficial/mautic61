FROM php:8.2-apache-bookworm

ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    cron \
    nodejs \
    npm \
    default-mysql-client \
    libicu-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
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
        intl \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        gd \
        mbstring \
        xml \
        imap \
        bcmath \
        sockets \
        xsl \
        opcache \
    && a2enmod rewrite \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && printf 'ServerName localhost\n' > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    && printf '<Directory /var/www/html>\n\
AllowOverride All\n\
Require all granted\n\
Options FollowSymLinks\n\
DirectoryIndex index.php index.html\n\
</Directory>\n' > /etc/apache2/conf-available/mautic.conf \
    && a2enconf mautic \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . /var/www/html

RUN rm -f composer.lock \
    && rm -rf vendor \
    && composer clear-cache \
    && chmod +x /var/www/html/bin/console \
    && COMPOSER_ALLOW_SUPERUSER=1 composer update --with-all-dependencies --no-interaction --no-scripts

RUN chown -R www-data:www-data /var/www/html \
    && mkdir -p /var/www/html/var /var/www/html/media \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod -R 775 /var/www/html/var /var/www/html/media

EXPOSE 80