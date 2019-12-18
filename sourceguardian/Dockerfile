FROM centos:7

ARG PHP_VERSION
ARG PHP_EXTENSIONS="bcmath cli common devel gd intl json mbstring \
    mcrypt sodium mysqlnd opcache pdo pecl-amqp pecl-redis process soap xml xmlrpc"

RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm \
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
    && yum install -y ${PHP_PACKAGES} git2u npm patch gettext unzip bzip2 \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install and enable Source Gaurdian loader
RUN PHP_VERSION=$(php -v | head -n1 | cut -d' ' -f2 | cut -d. -f1-2) \
    && mkdir -p /tmp/sourceguardian \
    && cd /tmp/sourceguardian \
    && curl -Os https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz \
    && tar xzf loaders.linux-x86_64.tar.gz \
    && cp ixed.${PHP_VERSION}.lin "$(php -i | grep '^extension_dir =' | cut -d' ' -f3)/sourceguardian.so" \
    && echo "extension=sourceguardian.so" > /etc/php.d/15-sourceguardian.ini \
    && rm -rf /tmp/sourceguardian
