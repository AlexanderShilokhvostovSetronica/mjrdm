FROM ubuntu:18.04

MAINTAINER Alexander Shilokhvostov <alex@shilli.ru>

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt update; apt install -y software-properties-common apt-utils

RUN add-apt-repository universe; \
    apt update; \
    loc=$(apt-cache policy language-pack-ru); \
    if echo $loc | grep -q -s -F "(none)"; then \
	apt install -y language-pack-ru ;\
    fi; \
    # Устанавливаем необходимые пакеты
    apt install -y git; \
    apt install -y apache2; \
    apt install -y apache2-bin; \
    apt install -y apache2-data; \
    apt install -y apache2-utils; \
    # apt install -y libapache2-mod-php; \
    apt install -y libapache2-mod-php7.2; \
    apt install -y libcurl3; \
    # apt install -y php-mysql; \
    apt install -y php7.2-mysql; \
    apt install -y php7.2-common; \
    apt install -y php7.2-json; \
    apt install -y php7.2-opcache; \
    apt install -y php7.2-readline; \
    apt install -y php7.2-bz2; \
    apt install -y php7.2-cli; \
    apt install -y php7.2-curl; \
    apt install -y php7.2-gd; \
    apt install -y php7.2-mbstring; \
    apt install -y php7.2-xml; \
    # apt install -y php-bcmath; \
    apt install -y php7.2-bcmath; \
    apt install -y php-pear; \
    apt install -y php7.2-dev; \
    apt install -y libmcrypt-dev; \
    apt install -y gcc; \
    apt install -y make; \
    apt install -y autoconf; \
    apt install -y libc6-dev; \
    apt install -y pkg-config; \
    pecl install mcrypt-1.0.1; \
    apt install -y dbconfig-mysql; \
    apt install -y mariadb-common; \
    apt install -y mariadb-client-10.1; \
    apt install -y iputils-ping; \
    apt install -y sudo
    # apt install -y phpmyadmin

RUN \
    # Настраиваем PHP для Apache
    echo "extension=mcrypt.so" | tee -a /etc/php/7.2/apache2/conf.d/mcrypt.ini; \
    sed -i '/short_open_tag/s/Off/On/' /etc/php/7.2/apache2/php.ini; \
    sed -i '/error_reporting/s/~E_DEPRECATED & ~E_STRICT/~E_NOTICE/' /etc/php/7.2/apache2/php.ini; \
    sed -i '/max_execution_time/s/30/90/' /etc/php/7.2/apache2/php.ini; \
    sed -i '/max_input_time/s/60/180/' /etc/php/7.2/apache2/php.ini; \
    sed -i '/post_max_size/s/8/200/' /etc/php/7.2/apache2/php.ini; \
    sed -i '/upload_max_filesize/s/2/50/' /etc/php/7.2/apache2/php.ini; \
    sed -i '/max_file_uploads/s/20/150/' /etc/php/7.2/apache2/php.ini; \
    # Настраиваем PHP для коммандной строки
    sed -i '/short_open_tag/s/Off/On/' /etc/php/7.2/cli/php.ini

RUN \
    # Создаем симлинк для PHPMyAdmin
    #ln -s /usr/share/phpmyadmin /var/www/phpmyadmin; \
    # Настраиваем Apache
    sed -i 's/None/All/g' /etc/apache2/apache2.conf; \
    echo "ServerName localhost" | tee -a /etc/apache2/apache2.conf; \
    sed -i 's/\/html//' /etc/apache2/sites-available/000-default.conf; \
    # Включаем мод rewrite для Apache
    a2enmod rewrite

# TODO refactor
#RUN chown -R www-data:www-data /var/www
#RUN usermod -a -G audio www-data
#RUN find /var/www/ -type f -exec sudo chmod 0666 {} \;
#RUN find /var/www/ -type d -exec sudo chmod 0777 {} \;

# supervisord
RUN apt-get -y install supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/www"]
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
