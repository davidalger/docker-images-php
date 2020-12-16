#!/usr/bin/env bash
set -e
trap 'error "$(printf "Command \`%s\` at $BASH_SOURCE:$LINENO failed with exit code $?" "$BASH_COMMAND")"' ERR

function error {
  >&2 printf "\033[31mERROR\033[0m: %s\n" "$@"
}

## find directory above where this script is located following symlinks if neccessary
readonly BASE_DIR="$(
  cd "$(
    dirname "$(
      (readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}") \
        | sed -e "s#^../#$(dirname "$(dirname "${BASH_SOURCE[0]}")")/#"
    )"
  )/.." >/dev/null \
  && pwd
)"
pushd "${BASE_DIR}" >/dev/null

## if --push is passed as first argument to script, this will login to docker hub and push images
PUSH_FLAG=
if [[ "${1:-}" = "--push" ]]; then
  PUSH_FLAG=1
fi

## login to docker hub as needed
if [[ $PUSH_FLAG ]]; then
  if [ -t 1 ]; then
    docker login
  else
    echo "${DOCKER_PASSWORD:-}" | docker login -u "${DOCKER_USERNAME:-}" --password-stdin
  fi
fi

## iterate over and build each version/variant combination; by default building
## latest version; build matrix will override to build each supported version
VERSION_LIST="${VERSION_LIST:-"7.3"}"
VARIANT_LIST="${VARIANT_LIST:-"cli cli-loaders fpm fpm-loaders"}"

export IMAGE_NAME="${IMAGE_NAME:-"davidalger/php"}"
DEFAULT_PACKAGE_REPO="${DEFAULT_PACKAGE_REPO:-"ius"}"
BUILD_PACKAGE_REPO_LIST="${BUILD_PACKAGE_REPO_LIST:-"ius remi"}"
for BUILD_PACKAGE_REPO in ${BUILD_PACKAGE_REPO_LIST}; do
  for BUILD_VERSION in ${VERSION_LIST}; do
    MAJOR_VERSION="$(echo "${BUILD_VERSION}" | sed -E 's/([0-9])([0-9])/\1.\2/')"
    for BUILD_VARIANT in ${VARIANT_LIST}; do
      # Configure build args specific to this image build
      export PHP_VERSION="${MAJOR_VERSION}"

      # Build the image passing list of tags and build args
      printf "\e[01;31m==> building %s:%s (%s, %s repository)\033[0m\n" \
        "${IMAGE_NAME}" "${BUILD_VERSION}" "${BUILD_VARIANT}" "${BUILD_PACKAGE_REPO}"

      # Strip the term 'cli' from tag suffix as this is the default variant
      TAG_SUFFIX="$(echo "${BUILD_VARIANT}" | sed -E 's/^(cli$|cli-)//')"
      [[ ${TAG_SUFFIX} ]] && TAG_SUFFIX="-${TAG_SUFFIX}"

      export IMAGE_SUFFIX=""
      [[ "${BUILD_PACKAGE_REPO}" != "${DEFAULT_PACKAGE_REPO}" ]] && IMAGE_SUFFIX="-${BUILD_PACKAGE_REPO}"
      [[ ${IMAGE_SUFFIX} ]] && TAG_SUFFIX="${IMAGE_SUFFIX}${TAG_SUFFIX}"

      BUILD_ARGS=(PHP_VERSION)
      docker build -t "${IMAGE_NAME}:build" "${BUILD_VARIANT}/${BUILD_PACKAGE_REPO}" \
        $(printf -- "--build-arg %s " "${BUILD_ARGS[@]}")

      # Fetch the precise php version from the built image and tag it
      MINOR_VERSION="$(docker run --rm -t --entrypoint php "${IMAGE_NAME}:build" -r 'echo phpversion();')"

      # Generate array of tags for the image being built
      IMAGE_TAGS=(
        "${IMAGE_NAME}:${MAJOR_VERSION}${TAG_SUFFIX}"
        "${IMAGE_NAME}:${MINOR_VERSION}${TAG_SUFFIX}"
      )

      # Iterate and push image tags to remote registry
      for TAG in "${IMAGE_TAGS[@]}"; do
        docker tag "${IMAGE_NAME}:build" "${TAG}"
        echo "Successfully tagged ${TAG}"
        [[ $PUSH_FLAG ]] && docker push "${TAG}"
      done
      docker rmi -f "${IMAGE_NAME}:build"
    done
  done
done
