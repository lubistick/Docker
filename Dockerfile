FROM alpine:3.21.0

RUN apk upgrade && \
    apk update && \
    apk add php84 \
        php84-ctype \
        php84-dom \
        php84-fileinfo \
        php84-iconv \
        php84-mbstring \
        php84-openssl \
        php84-pdo_pgsql \
        php84-phar \
        php84-session \
        php84-tokenizer \
        php84-xml \
        php84-xmlwriter && \
    ln -s /usr/bin/php84 /usr/bin/php && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

    # composer global require laravel/installer
    # /root/.composer/vendor/bin/laravel new example-app