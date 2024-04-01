# Utilise l'image officielle PHP avec Apache
FROM php:7.4-apache

# Active le mod_rewrite d'Apache et les modules SSL
RUN a2enmod rewrite ssl

# Installe les extensions PHP/MariaDB nécessaires
RUN apt-get update && apt-get install -y zlib1g-dev libpng-dev libzip-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-install pdo pdo_mysql mysqli gd zip

# Installe les outils LaTeX
RUN apt-get install -y texlive texlive-latex-extra texlive-lang-french

# Copie le certificat et la clé privée dans le conteneur
# Générez vos propres clés !
# COPY ./files/ssl/apache.crt /etc/ssl/certs/apache.crt
# COPY ./files/ssl/apache.key /etc/ssl/private/apache.key

# Génère les certificats auto-signé SSL, adapter selon votre configuration
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache.key -out /etc/ssl/certs/apache.crt -subj "/C=FR/ST=Paris/L=Paris/O=Security/OU=IT Department/CN=localhost"

# Remplace le fichier de configuration par défaut d'Apache pour activer SSL
COPY ./files/apache-ssl.conf /etc/apache2/sites-available/000-default.conf

# Expose le port 443 pour le trafic HTTPS
EXPOSE 80
EXPOSE 443

# Active le débogage PHP
RUN { \
        echo 'error_reporting = E_ALL'; \
        echo 'display_errors = On'; \
        echo 'display_startup_errors = On'; \
        echo 'log_errors = On'; \
        echo 'error_log = /var/log/php_errors.log'; \
    } > /usr/local/etc/php/conf.d/custom.ini

# Lance Apache en arrière-plan
CMD ["apache2-foreground"]

