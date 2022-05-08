#! /bin/sh

# exit when any command fails
set -e

# Config
IDZ_VORBIS_VERSION=1.3.5
IDZ_OGG_VERSION=$IDZ_OGG_VERSION

# Automatically set the iOS SDK version
IDZ_IOS_SDK_VERSION=`xcrun --sdk macosx --show-sdk-version`

pushd $IDZ_BUILD_ROOT

mkdir -p libvorbis/$IDZ_VORBIS_VERSION
pushd libvorbis/$IDZ_VORBIS_VERSION
curl -O https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-$IDZ_VORBIS_VERSION.tar.gz
tar xvfz libvorbis-$IDZ_VORBIS_VERSION.tar.gz

# Patch configure.ac
pushd libvorbis-$IDZ_VORBIS_VERSION
mv configure.ac configure.ac.orig
sed 's/-force_cpusubtype_ALL//' configure.ac.orig > configure.ac
./autogen.sh
make distclean
popd

# Simulator build
export IDZ_EXTRA_CONFIGURE_FLAGS=--with-ogg=$IDZ_BUILD_ROOT/libogg/$IDZ_OGG_VERSION/install-MacOSX-x86_64
idz_configure x86_64_osx $IDZ_IOS_SDK_VERSION libvorbis-$IDZ_VORBIS_VERSION/configure
export IDZ_EXTRA_CONFIGURE_FLAGS=--with-ogg=$IDZ_BUILD_ROOT/libogg/$IDZ_OGG_VERSION/install-MacOSX-arm64
idz_configure arm64_osx $IDZ_IOS_SDK_VERSION libvorbis-$IDZ_VORBIS_VERSION/configure

# Combine libraries
pushd install-MacOSX-x86_64/lib
idz_combine libvorbisall.a *.a
popd
pushd install-MacOSX-arm64/lib
idz_combine libvorbisall.a *.a
popd

# Create pseudo-framework
idz_fw Vorbis libvorbisall.a install-MacOSX-x86_64/include/vorbis "x86_64_osx arm64_osx"

# Back to where we started!
popd
