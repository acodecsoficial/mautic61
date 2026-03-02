FROM php:8.2-apache

# Instala dependências do sistema e bibliotecas necessárias
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev unzip git curl libonig-dev libxml2-dev \
    libcurl4-openssl-dev zip libc-client-dev libkrb5-dev \
    cron \
 && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
 && docker-php-ext-install intl pdo pdo_mysql zip gd mbstring xml curl \
      imap bcmath sockets \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Define ServerName para evitar o aviso do Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN a2enmod rewrite

WORKDIR /var/www/html

COPY . .

RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html

EXPOSE 80

# Instala o Composer e executa a instalação das dependências
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer \
 && composer install --no-dev --optimize-autoloader

CMD ["apache2-foreground"]