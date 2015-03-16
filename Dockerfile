FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
RUN echo "Europe/Paris" > /etc/timezone; dpkg-reconfigure tzdata

RUN apt-get update -y
RUN apt-get install -y git curl php5-cli php5-json php5-fpm php5-intl php5-curl php5-mysql php5-gd nginx supervisor

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Allow shell for www-data (to make composer commands)
RUN sed -i -e 's/\/var\/www:\/usr\/sbin\/nologin/\/var\/www:\/bin\/bash/' /etc/passwd

# CONF PHP-FPM
RUN sed -i "s/^listen\s*=.*$/listen = 127.0.0.1:9000/" /etc/php5/fpm/pool.d/www.conf
RUN sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini

# CONF Nginx 
ADD vhost.conf /etc/nginx/sites-enabled/default

# SUPERVISOR
ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

WORKDIR /var/www

EXPOSE 80
CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
