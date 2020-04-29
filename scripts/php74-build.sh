#!/usr/bin/bash
set -euo pipefail

RELEASEVER=${RELEASEVER:-7}
PKG_LIST=${PKG_LIST:-
  kelnei/oniguruma6
  davidalger/php74
  kelnei/php74-pecl-apcu
  kelnei/php74-pecl-igbinary
  kelnei/php74-pecl-msgpack
  kelnei/php74-pecl-redis
  davidalger/php74-pecl-amqp
  davidalger/php74-pecl-imagick
  davidalger/php74-pecl-xdebug
  davidalger/php74-pecl-zip
}
WORKSPACE="${GITHUB_WORKSPACE:-"$HOME"}"

yum --assumeyes install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm || true
yum --assumeyes install yum-utils rpmdevtools createrepo unzip @buildsys-build
yum --assumeyes install https://repo.ius.io/ius-release-el$(rpm -E %rhel).rpm || true

for PKG_REPO in ${PKG_LIST}; do
  echo "==> Building $PKG_REPO"
  PKG_NAME=$(echo $PKG_REPO | cut -d/ -f2)

  curl -sLo $WORKSPACE/$PKG_NAME.zip https://github.com/$PKG_REPO/archive/master.zip
  unzip -d $WORKSPACE $WORKSPACE/$PKG_NAME.zip && cd $WORKSPACE/$PKG_NAME-master

  RPMMACROS=(
    "%_sourcedir $PWD"
    "%_specdir $PWD"
    "%_topdir $WORKSPACE/rpmbuild"
    "%dist .el$RELEASEVER.ius"
    "%vendor IUS"
  )
  printf "%s\n" "${RPMMACROS[@]}" > $HOME/.rpmmacros

  if [[ ${PKG_NAME} =~ php74 ]]; then
    cat $WORKSPACE/patches/php74-gd-flags.patch | patch -p1
  fi

  if [[ ${PKG_NAME} =~ xdebug ]]; then
    printf "%s\n" "%_without_tests 1" >> $HOME/.rpmmacros
  fi

  if [[ ${PKG_NAME} =~ pecl-zip ]]; then
    yum install -y libzip1-devel --enablerepo ius-testing
  fi

  spectool --get-files $PKG_NAME.spec
  rpmbuild -bs $PKG_NAME.spec
  yum-builddep --assumeyes $WORKSPACE/rpmbuild/SRPMS/$PKG_NAME-*.src.rpm
  rpmbuild -bb $PKG_NAME.spec

  PKG_BUILT=$(
    ls -1 $WORKSPACE/rpmbuild/SRPMS/*$PKG_NAME*.src.rpm $WORKSPACE/rpmbuild/RPMS/*/*$PKG_NAME*.rpm
  )
  echo "==> Installing $PKG_BUILT"
  yum install -y $PKG_BUILT
done

echo "==> Creating SRPMS repo"
createrepo $WORKSPACE/rpmbuild/SRPMS

echo "==> Creating RPMS repo"
createrepo $WORKSPACE/rpmbuild/RPMS
