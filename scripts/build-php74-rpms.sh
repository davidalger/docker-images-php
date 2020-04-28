#!/usr/bin/bash
set -euo pipefail

RELEASEVER=${RELEASEVER:-7}
PKG_LIST=${PKG_LIST:-
  iusrepo/libzip1
  kelnei/oniguruma6
  davidalger/php74
  kelnei/php74-pecl-apcu
  kelnei/php74-pecl-igbinary
  kelnei/php74-pecl-msgpack
  kelnei/php74-pecl-redis
  davidalger/php74-pecl-amqp
  davidalger/php74-pecl-imagick
  davidalger/php74-pecl-xdebug
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

  if [[ ${PKG_NAME} =~ xdebug ]]; then
    printf "%s\n" "%_without_tests 1" >> $HOME/.rpmmacros
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

echo "==> Build Artifacts"
ls -1 $WORKSPACE/rpmbuild/SRPMS/*.src.rpm $WORKSPACE/rpmbuild/RPMS/*/*.rpm | sort

echo "==> Creating SRPMS repo"
createrepo $WORKSPACE/rpmbuild/SRPMS

echo "==> Creating RPMS repo"
createrepo $WORKSPACE/rpmbuild/RPMS
