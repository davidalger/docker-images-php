# PHP Docker Images

![Docker Image CI](https://github.com/davidalger/docker-images-php/workflows/Docker%20Image%20CI/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/davidalger/php.svg?label=Docker%20Pulls)

## Supported Tags

* `7.3`, `7.3-loaders`, `7.3-fpm`, `7.3-fpm-loaders`
* `7.2`, `7.2-loaders`, `7.2-fpm`, `7.2-fpm-loaders`
* `7.1`, `7.1-loaders`, `7.1-fpm`, `7.1-fpm-loaders`
* `7.0`, `7.0-loaders`, `7.0-fpm`, `7.0-fpm-loaders`
* `5.6`, `5.6-loaders`, `5.6-fpm`, `5.6-fpm-loaders`
* `5.5`, `5.5-loaders`, `5.5-fpm`, `5.5-fpm-loaders`

The `-loaders` suffix indicates the image includes both Source Guardian and IonCube loaders. These should be used when encoded PHP code is present in the project.

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

* [composer](https://hub.docker.com/_/composer) - dependency manager for PHP packages
* git - version control system (used by composer)
* npm - package manager for the Node JavaScript platform
* patch - apply a diff file to an original (used by composer)
* unzip - list, test and extract compressed files in a ZIP archive (used by composer)
* pwgen - password generator used in scripting creation of passwords meeting specific criteria
* ncat - networking utility which reads and writes data across networks from the command line
* jq - commandline JSON processor for use in scripts and pipelines
