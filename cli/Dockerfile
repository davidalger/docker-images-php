FROM centos:7

ARG PHP_VERSION
ARG PHP_EXTENSIONS="bcmath cli common gd gmp intl json mbstring \
    mcrypt sodium mysqlnd opcache pdo pecl-amqp pecl-redis pecl-imagick process soap xml xmlrpc zip"

RUN yum update -y \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN set -eux \
    && PHP_VERSION=$(echo ${PHP_VERSION} | awk -F '.' '{print $1$2}') \
    && yum install -y epel-release \
    && yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    && yum-config-manager --enable remi-php${PHP_VERSION} \
    && PHP_PACKAGES= && for PKG in ${PHP_EXTENSIONS}; do \
        if [[ ${PKG} = "mcrypt" ]] && (( ${PHP_VERSION} > 71 )); then continue; fi; \
        if [[ ${PKG} = "sodium" ]] && (( ${PHP_VERSION} < 72 )); then continue; fi; \
        PHP_PACKAGES+="php-${PKG} "; \
    done \
    && yum install -y php ${PHP_PACKAGES} perl which git npm patch gettext unzip bzip2 pwgen nmap-ncat jq \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp/composer
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer2

RUN cp /etc/php.ini /etc/php-cli.ini

RUN set -eux; \
    perl -pi -e 's/memory_limit(.*)/memory_limit=-1/g' /etc/php-cli.ini
