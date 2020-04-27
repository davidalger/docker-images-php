#!/usr/bin/bash
set -euo pipefail

RELEASEVER=7
PKG_LIST=(
  iusrepo/libzip1
  kelnei/oniguruma6
  # davidalger/php74
  # iusrepo/pear1
  # kelnei/php74-pecl-apcu
  # kelnei/php74-pecl-igbinary
  # kelnei/php74-pecl-msgpack
  # kelnei/php74-pecl-redis
)

yum install -y wget unzip
yum --assumeyes install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
yum --assumeyes install yum-utils rpmdevtools @buildsys-build

for PKG_REPO in ${PKG_LIST[@]}; do
  echo "==> Building $PKG_REPO"
  PKG_NAME=$(echo $PKG_REPO | cut -d/ -f2)

  wget https://github.com/$PKG_REPO/archive/master.zip -O $PKG_NAME.zip
  unzip -d / $PKG_NAME.zip && cd /$PKG_NAME-master

  cat > $HOME/.rpmmacros <<-EOT
		%_sourcedir $PWD
		%_specdir $PWD
		%_topdir $PWD
		%dist .el$RELEASEVER.ius
		%vendor IUS
	EOT

  spectool --get-files $PKG_NAME.spec
  rpmbuild -bs $PKG_NAME.spec
  yum-builddep --assumeyes $PWD/rpmbuild/SRPMS/$PKG_NAME-*.src.rpm
  rpmbuild -bb $PKG_NAME.spec

  PKG_BUILT=$(ls -1 $PWD/rpmbuild/SRPMS/*$PKG_NAME*.src.rpm $PWD/rpmbuild/RPMS/*/*$PKG_NAME*.rpm)
  echo "==> Installing $PKG_BUILT"
  yum install -y $PKG_BUILT
done

echo "==> Build Artifacts"
ls -1 $PWD/rpmbuild/SRPMS/*.src.rpm $PWD/rpmbuild/RPMS/*/*.rpm | sort
