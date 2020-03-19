#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace

JOBS="$(getconf _NPROCESSORS_ONLN)"

BINUTILS_VERSION=2.25.1
GCC_VERSION=7.5.0
BUILD_TARGET=x86_64-sun-solaris2.10

SYSROOT_VER=amd64-20200312-161829
SYSROOT_URL=https://illumos.org/downloads/sysroot-illumos-$SYSROOT_VER.tar.gz
SYSROOT_DIR=/ws/sysroot

BINUTILS_BASE=binutils-${BINUTILS_VERSION}
BINUTILS_URL=https://ftp.gnu.org/gnu/binutils/${BINUTILS_BASE}.tar.bz2

GCC_BASE=gcc-${GCC_VERSION}
GCC_URL=https://ftp.gnu.org/gnu/gcc/${GCC_BASE}/${GCC_BASE}.tar.xz

case "$1" in
sysroot)
	mkdir -p ${SYSROOT_DIR}
	cd ${SYSROOT_DIR}
	curl -L "$SYSROOT_URL" | tar xzf -
	;;

binutils)
	mkdir -p /ws/src/binutils
	cd /ws/src/binutils
	curl -L "$BINUTILS_URL" | tar xjf -

	mkdir -p /ws/build/binutils
	cd /ws/build/binutils
	/ws/src/binutils/${BINUTILS_BASE}/configure \
	    --target="${BUILD_TARGET}" \
	    --with-sysroot="${SYSROOT_DIR}"

	make -j "$JOBS"
	make install
	cd /ws
	rm -r /ws/src/binutils /ws/build/binutils
	;;

gcc)
	mkdir -p /ws/src/gcc
	cd /ws/src/gcc
	curl -L "${GCC_URL}" | tar xJf -

	mkdir /ws/build/gcc && \
	cd /ws/build/gcc && \
	export CFLAGS="-fPIC"
	export CXXFLAGS="-fPIC"
	export CXXFLAGS_FOR_TARGET="-fPIC"
	export CFLAGS_FOR_TARGET="-fPIC"
	/ws/src/gcc/${GCC_BASE}/configure \
	    --target=${BUILD_TARGET} \
	    --with-sysroot=${SYSROOT_DIR} \
	    --with-gnu-as \
	    --with-gnu-ld \
	    --disable-nls \
	    --disable-libgomp \
	    --disable-libquadmath \
	    --disable-libssp \
	    --disable-libvtv \
	    --disable-libcilkrts \
	    --disable-libada \
	    --disable-libsanitizer \
	    --disable-libquadmath-support \
	    --disable-shared \
	    --enable-tls
	make -j "$JOBS"
	make install
	cd /ws
	rm -r /ws/src/gcc /ws/build/gcc
	;;

*)
	printf 'ERROR: unknown phase "%s"\n' "$1" >&2
	exit 100

esac
