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

## if --push is passed as first argument to script, this will login to docker hub and push images
PUSH_FLAG=
if [[ "${1:-}" = "--push" ]]; then
  PUSH_FLAG=1
fi

## change into base directory and login to docker hub if neccessary
pushd ${BASE_DIR} >/dev/null
[[ $PUSH_FLAG ]] && docker login

## iterate over and build each version/variant combination
VERSION_LIST="${VERSION_LIST:-"55 56 70 71 72 73"}"
VARIANT_LIST="${VARIANT_LIST:-"cli fpm"}"

for PHP_VERSION in ${VERSION_LIST}; do
  for PHP_VARIANT in ${VARIANT_LIST}; do
    IMAGE_TAG="davidalger/php:$(echo ${PHP_VERSION} | sed -E 's/([0-9])([0-9])/\1.\2/')"
    if [[ ${PHP_VARIANT} != "cli" ]]; then
      IMAGE_TAG+="-${PHP_VARIANT}"
    fi

    export PHP_VERSION

    printf "\e[01;31m==> building ${IMAGE_TAG}\033[0m\n"
    docker build -t "${IMAGE_TAG}" --build-arg PHP_VERSION ${BASE_DIR}/${PHP_VARIANT}

    [[ $PUSH_FLAG ]] && docker push "${IMAGE_TAG}"
  done
done
