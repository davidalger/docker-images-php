#!/usr/bin/bash
set -euo pipefail

RELEASEVER=7
PKG_LIST=(
  iusrepo/libzip1
  kelnei/oniguruma6
  davidalger/php74
  iusrepo/pear1
  kelnei/php74-pecl-apcu
  kelnei/php74-pecl-igbinary
  kelnei/php74-pecl-msgpack
  kelnei/php74-pecl-redis
)

yum install -y wget unzip
yum --assumeyes install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
yum --assumeyes install yum-utils rpmdevtools @buildsys-build

for PKG_REPO in ${PKG_LIST[@]}; do
  echo "==> Building $PKG_REPO"
  PKG_NAME=$(echo $PKG_REPO | cut -d/ -f2)

  wget https://github.com/$PKG_REPO/archive/master.zip -O $PKG_NAME.zip
  unzip -d $GITHUB_WORKSPACE $PKG_NAME.zip && cd $GITHUB_WORKSPACE/$PKG_NAME-master

  RPMMACROS=(
    "%_sourcedir $PWD"
    "%_specdir $PWD"
    "%_topdir $WORKSPACE/rpmbuild"
    "%dist .el$RELEASEVER.ius"
    "%vendor IUS"
  )
  printf "%s\n" "${RPMMACROS[@]}" > $HOME/.rpmmacros

  spectool --get-files $PKG_NAME.spec
  rpmbuild -bs $PKG_NAME.spec
  yum-builddep --assumeyes $GITHUB_WORKSPACE/rpmbuild/SRPMS/$PKG_NAME-*.src.rpm
  rpmbuild -bb $PKG_NAME.spec

  PKG_BUILT=$(
    ls -1 $GITHUB_WORKSPACE/rpmbuild/SRPMS/*$PKG_NAME*.src.rpm $GITHUB_WORKSPACE/rpmbuild/RPMS/*/*$PKG_NAME*.rpm
  )
  echo "==> Installing $PKG_BUILT"
  yum install -y $PKG_BUILT
done

echo "==> Build Artifacts"
ls -1 $GITHUB_WORKSPACE/rpmbuild/SRPMS/*.src.rpm $GITHUB_WORKSPACE/rpmbuild/RPMS/*/*.rpm | sort
