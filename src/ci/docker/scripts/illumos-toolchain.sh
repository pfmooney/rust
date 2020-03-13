#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace

JOBS="$(getconf _NPROCESSORS_ONLN)"

BINUTILS_VERSION=2.25.1
GCC_VERSION=4.4.4
GCC_TARGET=x86_64-sun-solaris2.10

SYSROOT_VER=amd64-20200312-161829
SYSROOT_URL=https://illumos.org/downloads/sysroot-illumos-$SYSROOT_VER.tar.gz
BINUTILS_BASE=binutils-${BINUTILS_VERSION}
BINUTILS_URL=https://ftp.gnu.org/gnu/binutils/${BINUTILS_BASE}.tar.bz2

case "$1" in
sysroot)
	mkdir -p /ws/sysroot
	cd /ws/sysroot
	curl -L "$SYSROOT_URL" | tar xzf -
	;;

binutils)
	mkdir -p /ws/src/binutils
	cd /ws/src/binutils
	curl -L "$BINUTILS_URL" | tar xjf -

	mkdir -p /ws/build/binutils
	cd /ws/build/binutils
	/ws/src/binutils/binutils-${BINUTILS_VERSION}/configure \
	    --target="$GCC_TARGET" \
	    --with-sysroot="/ws/sysroot"

	make -j "$JOBS"
	make install
	;;

*)
	printf 'ERROR: unknown phase "%s"\n' "$1" >&2
	exit 100

esac
