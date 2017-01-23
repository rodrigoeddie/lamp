FROM ubuntu:latest
MAINTAINER Rodrigo de Melo <rodrigoeddie@gmail.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y upgrade && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server -y --fix-missing --fix-broken php5 php5-mysql php5-pgsql php5-sqlite php5-curl php5-mcrypt php5-gd php5-imagick php-pear openssl-blacklist pwgen php-apc && \
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/var/www/html/", "/etc/mysql", "/var/lib/mysql"]

EXPOSE 80 3306

CMD ["/bin/bash", "/start.sh"]
