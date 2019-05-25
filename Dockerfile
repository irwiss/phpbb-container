FROM alpine:3.9

ENV PHPBB_VERSION="3.2.7" \
    PHPBB_SHA256="223688db716c580f62ee9a92ce7147610b820f1da52b64ec2fbf9671597a4f77" \
    SERVER_NAME="localhost" \
    SERVER_ADMIN="webmaster@example.com" \
    PHPBB_INSTALL="false" \
    PHPBB_DB_DRIVER="postgres" \
    PHPBB_DB_HOST="localhost" \
    PHPBB_DB_PORT="5432" \
    PHPBB_DB_NAME="postgres" \
    PHPBB_DB_USER="postgres" \
    PHPBB_DB_PASSWD="" \
    PHPBB_DB_TABLE_PREFIX="phpbb_" \
    PHPBB_DB_WAIT="false" \
    PHPBB_DB_AUTOMIGRATE="false" \
    PHPBB_DISPLAY_LOAD_TIME="false" \
    PHPBB_DEBUG="false" \
    PHPBB_DEBUG_CONTAINER="false" \
    APACHE_ACCESS_LOG="/dev/stdout" \
    APACHE_ERROR_LOG="/dev/stderr"

RUN apk add --no-cache curl apache2 imagemagick php7 php7-apache2 php7-ctype php7-curl php7-dom php7-ftp php7-gd php7-iconv php7-json \
        php7-opcache php7-openssl php7-pgsql php7-tokenizer php7-xml php7-zlib php7-zip su-exec \
    && cd /tmp \
    && curl -sSL https://www.phpbb.com/files/release/phpBB-${PHPBB_VERSION}.tar.bz2 -o phpbb.tar.bz2 \
    && echo "${PHPBB_SHA256}  phpbb.tar.bz2" | sha256sum -c - \
    && tar -xjf phpbb.tar.bz2 \
    && mkdir -p /phpbb /run/apache2 /phpbb/opcache \
    && mv phpBB3 /phpbb/www \
    && rm -f phpbb.tar.bz2 \
    && deluser xfs \
    && delgroup www-data \
    && addgroup -g 33 www-data \
    && adduser -D -H -h /var/www -u 33 -G www-data www-data

COPY phpbb/config.php /phpbb/www
COPY apache2/httpd.conf /etc/apache2/
COPY apache2/conf.d/* /etc/apache2/conf.d/
COPY php/php.ini /etc/php7/
COPY php/php-cli.ini /etc/php7/
COPY php/conf.d/* /etc/php7/conf.d/
COPY start.sh /usr/local/bin/

RUN chown -R www-data:www-data /phpbb /run/apache2 \
    && chmod +x /usr/local/bin/start.sh \
    && chmod 440 /phpbb/www/config.php \
    && chmod -R -x+X /phpbb

WORKDIR /phpbb/www

CMD ["start.sh"]
