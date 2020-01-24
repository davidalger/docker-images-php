# PHP Docker Images

![Docker Image CI](https://github.com/davidalger/docker-images-php/workflows/Docker%20Image%20CI/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/davidalger/php.svg?label=Docker%20Pulls)

## Supported Tags

* 7.3, 7.3-fpm
* 7.2, 7.2-fpm
* 7.1, 7.1-fpm
* 7.0, 7.0-fpm
* 5.6, 5.6-fpm
* 5.5, 5.5-fpm

## Additional Extensions

These images are based on the `centos:7` image using the IUS RPMs to install PHP including the following extensions:

* bcmath
* gd
* intl
* json
* mbstring
* mcrypt (7.1 and lower)
* sodium (7.2 and greater)
* mysqlnd
* opcache
* pdo
* pecl-redis
* process
* soap
* xml
* xmlrpc

## Other Inclusions

* [Composer](https://hub.docker.com/_/composer) copied in from the official `composer` image.
* The `git`, `npm`, `patch`, `unzip`, `pwgen` and `nmap-ncat` packages are pre-installed to accommodate composer and other common build requirements when these images are used in Concourse pipelines or similar.
