FROM ubuntu:18.04

# Enable source repositories, which are disabled by default on Ubuntu >= 18.04
RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list

COPY scripts/cross-apt-packages.sh /tmp/
RUN bash /tmp/cross-apt-packages.sh

#RUN apt-get update && \
#  apt-get build-dep -y clang llvm

COPY scripts/illumos-toolchain.sh /tmp/

RUN bash /tmp/illumos-toolchain.sh sysroot
RUN bash /tmp/illumos-toolchain.sh binutils
#RUN bash /tmp/illumos-toolchain-2.sh gcc

ENV GCCV=7.5.0
RUN mkdir /ws/src/gcc && \
    cd /ws/src/gcc && \
    curl -L https://ftp.gnu.org/gnu/gcc/gcc-$GCCV/gcc-$GCCV.tar.xz | tar xJf -

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev

RUN mkdir /ws/build/gcc && \
    cd /ws/build/gcc && \
    /ws/src/gcc/gcc-${GCCV}/configure \
        --target=x86_64-sun-solaris2.10 \
        --with-sysroot=/ws/sysroot \
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
        --enable-tls \
    && make -j16 \
    && make install


#COPY scripts/sccache.sh /scripts/
#RUN sh /scripts/sccache.sh

ENV \
    AR_x86_64_sun_solaris=x86_64-sun-solaris2.10-ar \
    CC_x86_64_sun_solaris=x86_64-sun-solaris2.10-gcc \
    CXX_x86_64_sun_solaris=x86_64-sun-solaris2.10-g++

ENV TARGETS=x86_64-sun-solaris
#ENV HOSTS=x86_64-sun-solaris

ENV RUST_CONFIGURE_ARGS --enable-extended --disable-docs
#ENV SCRIPT python2.7 ../x.py dist --host $HOSTS --target $HOSTS
ENV SCRIPT python2.7 ../x.py dist --target $TARGETS
