FROM    php:7.1.2-fpm-alpine
WORKDIR /usr/src/data
COPY    ./php.ini   /usr/local/etc/php/
COPY    ../../back-end/    /var/www/data/
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
      docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
      NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
      docker-php-ext-install -j${NPROC} gd && \
      apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev