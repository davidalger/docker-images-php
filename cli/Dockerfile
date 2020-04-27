FROM centos:7

ARG PHP_VERSION
ARG PHP_EXTENSIONS="bcmath cli common gd gmp intl json mbstring \
    mcrypt sodium mysqlnd opcache pdo pecl-amqp pecl-redis pecl-imagick process soap xml xmlrpc"

RUN yum upgrade -y --exclude=centos-release \
    && yum clean all \
    && rm -rf /var/cache/yum

# When building PHP 7.4 images ./php7.4/php74-rpms will be copied to /tmp/php74-rpms
COPY Dockerfile php${PHP_VERSION}* /tmp/

RUN set -eux \
    && PHP_VERSION=$(echo ${PHP_VERSION} | awk -F '.' '{print $1$2}') \
    && yum install -y https://repo.ius.io/ius-release-el7.rpm \
    && yum-config-manager --enable ius-archive \
    && if (( ${PHP_VERSION} >= 73 )); \
        then PHP_PKG_PREFIX=php${PHP_VERSION}; \
        else PHP_PKG_PREFIX=php${PHP_VERSION}u; \
    fi \
    && PHP_PACKAGES= && for PKG in ${PHP_EXTENSIONS}; do \
        if [[ ${PKG} = "pecl-amqp" ]] && (( ${PHP_VERSION} < 71 )); then continue; fi; \
        if [[ ${PKG} = "mcrypt" ]] && (( ${PHP_VERSION} > 71 )); then continue; fi; \
        if [[ ${PKG} = "sodium" ]] && (( ${PHP_VERSION} < 72 )); then continue; fi; \
        PHP_PACKAGES+="${PHP_PKG_PREFIX}-${PKG} "; \
    done \
    && if (( ${PHP_VERSION} == 74 )); then \
        PHP_EXTENSIONS="${PHP_PACKAGES} php74-pecl-msgpack php74-pecl-igbinary oniguruma6 jq"; \
        PHP_PACKAGES= && for PKG in ${PHP_EXTENSIONS}; do \
            RPM="$(find /tmp/php74-rpms -regex ".*/${PKG}-[0-9\.\-]+.el7.ius.x86_64.rpm")"; \
            if [[ "${RPM}" ]]; \
                then PHP_PACKAGES+="${RPM} "; \
                else echo "Package ${PKG} unavailable"; \
            fi \
        done; \
        yum install -y ${PHP_PACKAGES}; \
    fi \
    && yum install -y ${PHP_PACKAGES} git222 npm patch gettext unzip bzip2 pwgen nmap-ncat jq \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp/composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
