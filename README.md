# PHP Docker Images

![Docker Image CI](https://github.com/davidalger/docker-images-php/workflows/Docker%20Image%20CI/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/davidalger/php.svg?label=Docker%20Pulls)

## Supported Tags

Images are built and tagged using both stable and version specific tags to support pinning downstream builds to latest available for `7.4` or to a specific version such as `7.4.16`. Please reference the [image repository](https://hub.docker.com/r/davidalger/php) on Docker Hub for a complete list of available tags. Builds are automatically run on the 1st of each month and/or when changes are pushed to the master branch of this repository.

* `8.0`, `8.0-loaders`, `8.0-fpm`, `8.0-fpm-loaders`
* `7.4`, `7.4-loaders`, `7.4-fpm`, `7.4-fpm-loaders`
* `7.3`, `7.3-loaders`, `7.3-fpm`, `7.3-fpm-loaders`
* `7.2`, `7.2-loaders`, `7.2-fpm`, `7.2-fpm-loaders`

The `-loaders` suffix indicates the image includes both Source Guardian and IonCube loaders. These should only be used when encoded PHP is present in a project.

Images for older versions of PHP may be available (see Docker Hub for available tags) but they are no longer actively maintained.

## Additional Extensions

These images are based on the `centos:8` image using the Remi's RPMs Repository to install PHP including the following extensions:

* bcmath
* gd
* gmp
* intl
* json
* mbstring
* msgpack
* sodium
* mysqlnd
* opcache
* pdo
* amqp
* redis
* imagick
* process
* soap
* xml
* xmlrpc
* zip

## Other Inclusions

* [composer](https://hub.docker.com/_/composer) - dependency manager for PHP packages
* git - version control system (used by composer)
* npm - package manager for the Node JavaScript platform
* patch - apply a diff file to an original (used by composer)
* unzip - list, test and extract compressed files in a ZIP archive (used by composer)
* pwgen - password generator used in scripting creation of passwords meeting specific criteria
* ncat - networking utility which reads and writes data across networks from the command line
* jq - commandline JSON processor for use in scripts and pipelines
