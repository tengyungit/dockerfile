FROM centos:7
MAINTAINER krowpang <krowpang@gmail.com>

ENV NGINX_VERSION 1.11.13
ENV PHP_VERSION 7.0.24

RUN set -x && \

#Add user
    mkdir -p /data/{www,phpext,log} && \
    useradd -r -s /sbin/nologin -d /data/www -m -k no www && \
    chown -R www:www /data/www && \

#Download nginx & php
    mkdir -p /home/nginx-php && cd $_ && \
    curl -Lk http://pecl.php.net/get/mongodb-1.1.8.tgz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk http://pecl.php.net/get/redis-3.1.4.tgz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk http://php.net/distributions/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \    
    curl -Lk http://pecl.php.net/get/zookeeper-0.4.0.tgz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk http://mirrors.cnnic.cn/apache/zookeeper/zookeeper-3.5.0-alpha/zookeeper-3.5.0-alpha.tar.gz | gunzip | tar x -C /home/nginx-php && \

#    curl -Lk http://192.168.1.121/software/mongodb-1.1.8.tgz | gunzip | tar x -C /home/nginx-php && \
#    curl -Lk http://192.168.1.121/software/zookeeper-0.4.0.tgz | gunzip | tar x -C /home/nginx-php && \
#    curl -Lk http://192.168.1.121/software/redis-3.1.4.tgz | gunzip | tar x -C /home/nginx-php && \
#    curl -Lk http://192.168.1.121/software/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
#    curl -Lk http://192.168.1.121/software/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
#    curl -Lk http://192.168.1.121/software/zookeeper-3.5.0-alpha.tar.gz | gunzip | tar x -C /home/nginx-php && \
#    ls -a /home/nginx-php && \

#Install make tool
    yum install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \

#Install PHP library
## libmcrypt-devel DIY
    rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
    yum install -y zlib \
    zlib-devel \
    openssl \
    openssl-devel \
    pcre-devel \
    libxml2 \
    libxml2-devel \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
    python-setuptools && \

#Make install nginx
    cd /home/nginx-php/nginx-$NGINX_VERSION && \
    ./configure --prefix=/usr/local/nginx \
    --user=www --group=www \
    --error-log-path=/var/log/nginx_error.log \
    --http-log-path=/var/log/nginx_access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make && make install && \

#Make install php
    cd /home/nginx-php/php-$PHP_VERSION && \
    ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir=/usr/local/php/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mcrypt=/usr/include \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-session \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --disable-debug \
    --without-pear && \
    make && make install && \

#Install php-fpm
    cd /home/nginx-php/php-$PHP_VERSION && \
    cp php.ini-production /usr/local/php/etc/php.ini && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf && \
    sed -i 's/display_errors = Off/display_errors = On/g'  /usr/local/php/etc/php.ini && \
    sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/' /usr/local/php/etc/php.ini && \

    
#Install zookeeper
    cd /home/nginx-php/zookeeper-3.5.0-alpha/src/c && \
    ./configure --prefix=/usr/local/zookeeper/zookeeper-3.5.0 && \
    make && make install && \

    
#Install php extension mongodb
    cd /home/nginx-php/mongodb-1.1.8 && \
    /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config && \
    make && make install && \

#Add php extension redis
    cd /home/nginx-php/redis-3.1.4 && \
    /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config && \
    make && make install && \


#Add php extension zookeeper
    cd /home/nginx-php/zookeeper-0.4.0 && \
    /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config --with-libzookeeper-dir=/usr/local/zookeeper/zookeeper-3.5.0/ && \
    make && make install && \

#Install supervisor
    easy_install supervisor && \
    mkdir -p /var/{log/supervisor,run/{sshd,supervisord}} && \

#Clean OS
    yum remove -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    yum clean all && \
    rm -rf /tmp/* /var/cache/{yum,ldconfig} /etc/my.cnf{,.d} && \
    mkdir -p --mode=0755 /var/cache/{yum,ldconfig} && \
    find /var/log -type f -delete && \
    rm -rf /home/nginx-php

#Change Mod from webdir
#    chown -R www:www /data/www

#Add supervisord conf
ADD supervisord.conf /etc/

RUN chown -R www:www /data/www && \
    chown www:www /data/log && chmod 766 /data/log && \
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
 
    sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/' /usr/local/php/etc/php.ini && \
    sed -i 's/;error_log = php_errors.log/error_log = \/data\/log\/php_errors.log/' /usr/local/php/etc/php.ini && \
    sed -i 's/session.name = PHPSESSID/session.name = JSESSID/' /usr/local/php/etc/php.ini && \
    sed -i 's/;error_log = log\/php-fpm.log/error_log = \/data\/log\/php-fpm.log/' /usr/local/php/etc/php-fpm.conf


#Create web folder
VOLUME ["/data/log", "/data/www/runtime","/data/www", "/usr/local/nginx/conf/ssl", "/usr/local/nginx/conf/vhost", "/usr/local/php/etc/php.d", "/data/phpext"]

ADD index.php /data/www/
ADD .nginx/web.conf /usr/local/nginx/conf/vhost/web.conf

ADD extini/ /usr/local/php/etc/php.d/
ADD extfile/ /data/phpext/

#Update nginx config
ADD nginx.conf /usr/local/nginx/conf/

#Start
ADD start.sh /
RUN chmod +x /start.sh

#Set port
EXPOSE 80 443

#Start it
ENTRYPOINT ["/start.sh"]

#Start web server
#CMD ["/bin/bash", "/start.sh"]
