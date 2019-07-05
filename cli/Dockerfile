FROM centos:7

ARG PHP_VERSION
ARG PHP_EXTENSIONS="bcmath cli common devel gd imap intl json mbstring \
    mcrypt sodium mysqlnd opcache pdo pecl-redis process soap xml xmlrpc"

RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm \
    && yum-config-manager --enable ius-archive \
    && if (( ${PHP_VERSION} >= 73 )); \
        then PHP_PKG_PREFIX=php${PHP_VERSION}; \
        else PHP_PKG_PREFIX=php${PHP_VERSION}u; \
    fi \
    && PHP_PACKAGES= && for PKG in ${PHP_EXTENSIONS}; do \
        if [[ ${PKG} = "mcrypt" ]] && (( ${PHP_VERSION} > 71 )); then continue; fi; \
        if [[ ${PKG} = "sodium" ]] && (( ${PHP_VERSION} < 72 )); then continue; fi; \
        PHP_PACKAGES+="${PHP_PKG_PREFIX}-${PKG} "; \
    done \
    && yum install -y ${PHP_PACKAGES} git npm patch gettext unzip \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
COPY --from=composer /usr/bin/composer /usr/bin/composer
