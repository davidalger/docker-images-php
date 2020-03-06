#!/usr/bin/env bash
set -e
trap '>&2 printf "\n\e[01;31mError: Command \`%s\` on line $LINENO failed with exit code $?\033[0m\n" "$BASH_COMMAND"' ERR

## find directory where this script is located following symlinks if neccessary
readonly BASE_DIR="$(
  cd "$(
    dirname "$(
      (readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}") \
        | sed -e "s#^../#$(dirname "$(dirname "${BASH_SOURCE[0]}")")/#"
    )"
  )" >/dev/null \
  && pwd
)/.."
pushd ${BASE_DIR} >/dev/null

## if --push is passed as first argument to script, this will login to docker hub and push images
PUSH_FLAG=
if [[ "${1:-}" = "--push" ]]; then
  PUSH_FLAG=1
fi

## login to docker hub as needed
if [[ $PUSH_FLAG ]]; then
  [ -t 1 ] && docker login \
    || echo "${DOCKER_PASSWORD:-}" | docker login -u "${DOCKER_USERNAME:-}" --password-stdin
fi

## iterate over and build each version/variant combination
VERSION_LIST="${VERSION_LIST:-"55 56 70 71 72 73"}"
VARIANT_LIST="${VARIANT_LIST:-"cli cli-loaders fpm fpm-loaders"}"

for PHP_VERSION in ${VERSION_LIST}; do
  for PHP_VARIANT in ${VARIANT_LIST}; do
    IMAGE_TAG="davidalger/php:$(echo ${PHP_VERSION} | sed -E 's/([0-9])([0-9])/\1.\2/')"
    IMAGE_TAG_SUFFIX="$(echo ${PHP_VARIANT} | sed -E 's/^(cli$|cli-)//')"
    if [[ ${IMAGE_TAG_SUFFIX} ]]; then
      IMAGE_TAG+="-${IMAGE_TAG_SUFFIX}"
    fi

    export PHP_VERSION

    printf "\e[01;31m==> building ${IMAGE_TAG}\033[0m\n"
    docker build -t "${IMAGE_TAG}" --build-arg PHP_VERSION ${BASE_DIR}/${PHP_VARIANT}

    [[ $PUSH_FLAG ]] && docker push "${IMAGE_TAG}"
  done
done
