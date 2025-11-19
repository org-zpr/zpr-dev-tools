FROM linuxcontainers/debian-slim:12
LABEL org.opencontainers.image.source=https://github.com/org-zpr/zpr-dev-tools
LABEL org.opencontainers.image.description="zpr build env DEB"

SHELL ["/bin/bash", "-c"]

WORKDIR /opt

RUN apt-get -y update \
&& apt-get install -y wget curl build-essential git \
&& apt autoremove


# deps for thrift (most of these) and Cap'n Proto (just capnproto)
RUN apt-get install -y \
libboost-dev libboost-test-dev libboost-program-options-dev libboost-filesystem-dev libboost-thread-dev \
libevent-dev automake libtool flex bison pkg-config g++ libssl-dev capnproto \
&& apt autoremove


# go:
RUN wget -nv https://go.dev/dl/go1.25.0.linux-amd64.tar.gz \
&& tar xf go1.25.0.linux-amd64.tar.gz \
&& mkdir -p /opt/gopath

ENV GOPATH=/opt/gopath
ENV GOROOT=/opt/go


# rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup.sh \
&& /bin/sh ./rustup.sh --default-toolchain stable -y



# thrift
RUN wget -nv https://archive.apache.org/dist/thrift/0.17.0/thrift-0.17.0.tar.gz \
&& tar xf thrift-0.17.0.tar.gz \
&& cd thrift-0.17.0 \
&& ./bootstrap.sh \
&& ./configure --with-go --with-rs --without-python --without-py3 --without-swift --without-php --without-kotlin --without-java --without-nodejs --without-netstd --disable-tests --disable-tutorial --disable-dependency-tracking \
&& make && make install \
&& cd /opt \
&& rm -rf thrift-0.17.0 && rm thrift-0.17.0.tar.gz




ENV PATH="$PATH:/opt/go/bin:/root/.cargo/bin"
