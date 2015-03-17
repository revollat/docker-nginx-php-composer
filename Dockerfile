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
RUN sed -i "s/display_errors = .*/display_errors = stderr/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone.*/date.timezone = Europe\/Paris/" /etc/php5/fpm/php.ini

# CONF PHP-CLI
RUN sed -i "s/;date.timezone.*/date.timezone = Europe\/Paris/" /etc/php5/cli/php.ini
	
# CONF Nginx 
ADD vhost.conf /etc/nginx/sites-enabled/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# SUPERVISOR
ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

WORKDIR /var/www

EXPOSE 80
CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
