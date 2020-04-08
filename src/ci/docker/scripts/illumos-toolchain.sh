#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace

JOBS="$(getconf _NPROCESSORS_ONLN)"

case "$1" in
x86_64)
	SYSROOT_MACH='amd64'
	;;
*)
	printf 'ERROR: unknown architecture: %s\n' "$1"
	exit 1
esac

BUILD_TARGET="$1-sun-solaris2.10"

#
# NOTE: The compiler version selected here is more specific than might appear.
# GCC 7.X releases do not appear to cross-compile correctly for Solaris
# targets, at least insofar as they refuse to enable TLS in libstdc++.  When
# changing the GCC version in future, one must carefully verify that TLS is
# enabled in all of the static libraries we intend to include in output
# binaries.
#
GCC_VERSION='8.4.0'
GCC_MD5='bb815a8e3b7be43c4a26fa89dbbd9795'
GCC_BASE="gcc-$GCC_VERSION"
GCC_TAR="gcc-$GCC_VERSION.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/$GCC_BASE/$GCC_TAR"

SYSROOT_VER="$SYSROOT_MACH-20200312-161829"
SYSROOT_MD5='d61f8d2e10cc12b97ccd8b92b80493a2'
SYSROOT_TAR="sysroot-illumos-$SYSROOT_VER.tar.gz"
SYSROOT_URL="https://illumos.org/downloads/$SYSROOT_TAR"
SYSROOT_DIR='/ws/sysroot'

BINUTILS_VERSION='2.25.1'
BINUTILS_MD5='ac493a78de4fee895961d025b7905be4'
BINUTILS_BASE="binutils-$BINUTILS_VERSION"
BINUTILS_TAR="$BINUTILS_BASE.tar.bz2"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/$BINUTILS_TAR"


download_file() {
	local file="$1"
	local url="$2"
	local md5="$3"

	while :; do
		if [[ -f "$file" ]]; then
			if ! h="$(md5sum "$file" | awk '{ print $1 }')"; then
				printf 'ERROR: reading hash\n' >&2
				exit 1
			fi

			if [[ "$h" == "$md5" ]]; then
				return 0
			fi

			printf 'WARNING: hash mismatch: %s != expected %s\n' \
			    "$h" "$md5" >&2
			rm -f "$file"
		fi

		printf 'Downloading: %s\n' "$url"
		if ! curl -f -L -o "$file" "$url"; then
			rm -f "$file"
			sleep 1
		fi
	done
}

case "$2" in
sysroot)
	download_file "/tmp/$SYSROOT_TAR" "$SYSROOT_URL" "$SYSROOT_MD5"
	mkdir -p "$SYSROOT_DIR"
	cd "$SYSROOT_DIR"
	tar -xzf "/tmp/$SYSROOT_TAR"
	rm -f "/tmp/$SYSROOT_TAR"
	;;

binutils)
	download_file "/tmp/$BINUTILS_TAR" "$BINUTILS_URL" "$BINUTILS_MD5"
	mkdir -p /ws/src/binutils
	cd /ws/src/binutils
	tar -xjf "/tmp/$BINUTILS_TAR"
	rm -f "/tmp/$BINUTILS_TAR"

	mkdir -p /ws/build/binutils
	cd /ws/build/binutils
	"/ws/src/binutils/$BINUTILS_BASE/configure" \
	    --target="$BUILD_TARGET" \
	    --with-sysroot="$SYSROOT_DIR"

	make -j "$JOBS"
	make install

	cd /
	rm -rf /ws/src/binutils /ws/build/binutils
	;;

gcc)
	download_file "/tmp/$GCC_TAR" "$GCC_URL" "$GCC_MD5"
	mkdir -p /ws/src/gcc
	cd /ws/src/gcc
	tar -xJf "/tmp/$GCC_TAR"
	rm -f "/tmp/$GCC_TAR"

	mkdir -p /ws/build/gcc
	cd /ws/build/gcc
	export CFLAGS='-fPIC'
	export CXXFLAGS='-fPIC'
	export CXXFLAGS_FOR_TARGET='-fPIC'
	export CFLAGS_FOR_TARGET='-fPIC'
	"/ws/src/gcc/$GCC_BASE/configure" \
	    --target="$BUILD_TARGET" \
	    --with-sysroot="$SYSROOT_DIR" \
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

	cd /
	rm -rf /ws/src/gcc /ws/build/gcc
	;;

*)
	printf 'ERROR: unknown phase "%s"\n' "$1" >&2
	exit 100
	;;
esac
