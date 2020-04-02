FROM ubuntu:18.04

# Enable source repositories, which are disabled by default on Ubuntu >= 18.04
RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list

COPY scripts/cross-apt-packages.sh /tmp/
RUN bash /tmp/cross-apt-packages.sh

# Required for cross-build gcc
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libgmp-dev \
      libmpfr-dev \
      libmpc-dev

COPY scripts/illumos-toolchain.sh /tmp/

RUN bash /tmp/illumos-toolchain.sh x86_64 sysroot
RUN bash /tmp/illumos-toolchain.sh x86_64 binutils
RUN bash /tmp/illumos-toolchain.sh x86_64 gcc

COPY scripts/sccache.sh /scripts/
RUN sh /scripts/sccache.sh

ENV \
    AR_x86_64_sun_solaris=x86_64-sun-solaris2.10-ar \
    CC_x86_64_sun_solaris=x86_64-sun-solaris2.10-gcc \
    CXX_x86_64_sun_solaris=x86_64-sun-solaris2.10-g++

ENV HOSTS=x86_64-sun-solaris

ENV RUST_CONFIGURE_ARGS --enable-extended --disable-docs
ENV SCRIPT python2.7 ../x.py dist --host $HOSTS --target $HOSTS
