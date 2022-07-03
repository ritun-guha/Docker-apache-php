FROM ubuntu:20.04
MAINTAINER Ritun Guha, ritun.guha21@gmail.com

# Install Apache2
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install apache2

# Set apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Set Timezone 
ENV TZ=Asia/Calcutta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Additional Packages
RUN apt-get install -y libmcrypt-dev openssl curl git wget libssl-dev autoconf g++ make pkg-config \
    vim zip unzip

# Install PHP 7.4 and PHP Extensions
RUN apt-get install -y libapache2-mod-php7.4 php7.4 php7.4-cli php7.4-xdebug php7.4-mbstring php7.4-mysql php7.4-imagick \
    php7.4-memcached php-pear imagemagick php7.4-dev php7.4-gd php7.4-json php7.4-curl php7.4-intl php7.4-mongodb php7.4-zip \
    php7.4-xml

# Install Composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN cd /etc/apache2/sites-available && a2ensite 000-default.conf && service apache2 restart

# Enable apache mods
RUN a2enmod php7.4
RUN a2enmod rewrite
RUN service apache2 restart

# Update php.ini file, enable short tags <? ?> and error logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.4/apache2/php.ini

VOLUME ["/var/www/html"]
WORKDIR /var/www/html

EXPOSE 8080:80

# Copy this repo into place.
ADD www /var/www/html

# Update the default apache site with the config we created.
ADD config/vhost.conf /etc/apache2/sites-enabled/000-default.conf
ADD config/apache2.conf /etc/apache2/apache2.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND
