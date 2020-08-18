FROM centos:7

ARG PHP_VERSION
ARG PHP_EXTENSIONS="bcmath cli common gd gmp intl json mbstring \
    mcrypt sodium mysqlnd opcache pdo pecl-amqp pecl-redis pecl-imagick pecl-zip process soap xml xmlrpc"

RUN yum update -y \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN set -eux \
    && PHP_VERSION=$(echo ${PHP_VERSION} | awk -F '.' '{print $1$2}') \
    && yum install -y https://repo.ius.io/ius-release-el7.rpm \
    && if (( ${PHP_VERSION} <= 71 )); then \
        yum-config-manager --enable ius-archive; \
        yum --enablerepo C7.7.1908-base install -y ImageMagick-6.7.8.9-18.el7; \
    fi \
    && if (( ${PHP_VERSION} == 74 )); then \
        yum-config-manager --enable ius-testing; \
    fi \
    && if (( ${PHP_VERSION} >= 73 )); \
        then PHP_PKG_PREFIX=php${PHP_VERSION}; \
        else PHP_PKG_PREFIX=php${PHP_VERSION}u; \
    fi \
    && PHP_PACKAGES= && for PKG in ${PHP_EXTENSIONS}; do \
        if [[ ${PKG} = "pecl-amqp" ]] && (( ${PHP_VERSION} < 71 )); then continue; fi; \
        if [[ ${PKG} = "pecl-zip" ]] && (( ${PHP_VERSION} < 74 )); then continue; fi; \
        if [[ ${PKG} = "mcrypt" ]] && (( ${PHP_VERSION} > 71 )); then continue; fi; \
        if [[ ${PKG} = "sodium" ]] && (( ${PHP_VERSION} < 72 )); then continue; fi; \
        PHP_PACKAGES+="${PHP_PKG_PREFIX}-${PKG} "; \
    done \
    && yum install -y ${PHP_PACKAGES} git222 npm patch gettext unzip bzip2 pwgen nmap-ncat jq \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp/composer
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer
