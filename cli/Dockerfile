FROM centos:7

ARG PHP_VERSION
ARG PHP_EXTENSIONS="bcmath cli common gd gmp intl json mbstring \
    mcrypt sodium mysqlnd opcache pdo pecl-amqp pecl-redis pecl-imagick pecl-zip process soap xml xmlrpc"

RUN yum upgrade -y --exclude=centos-release \
    && yum clean all \
    && rm -rf /var/cache/yum

# When building PHP 7.4 images copy ./php7.4/php74 and ./php7.4/php74-src into /var/
COPY Dockerfile php${PHP_VERSION}* /var/
RUN rm -f /var/Dockerfile

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
        if [[ ${PKG} = "pecl-zip" ]] && (( ${PHP_VERSION} < 74 )); then continue; fi; \
        if [[ ${PKG} = "mcrypt" ]] && (( ${PHP_VERSION} > 71 )); then continue; fi; \
        if [[ ${PKG} = "sodium" ]] && (( ${PHP_VERSION} < 72 )); then continue; fi; \
        PHP_PACKAGES+="${PHP_PKG_PREFIX}-${PKG} "; \
    done \
    && if (( ${PHP_VERSION} == 74 )); then \
        PHP74_REPO=( \
            "[php74]" \
            "name = PHP 7.4 based on IUS for Enterprise Linux 7" \
            "baseurl = file:///var/php74" \
            "gpgcheck = 0" \
            "enabled = 1" \
            "" \
            "[php74-source]" \
            "name = PHP 7.4 based on IUS for Enterprise Linux 7 - Source" \
            "baseurl = file:///var/php74-src" \
            "gpgcheck = 0" \
            "enabled = 0" \
        ); \
        printf "%s\n" "${PHP74_REPO[@]}" > /etc/yum.repos.d/php74.repo; \
    fi \
    && yum install -y ${PHP_PACKAGES} git222 npm patch gettext unzip bzip2 pwgen nmap-ncat jq \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp/composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
