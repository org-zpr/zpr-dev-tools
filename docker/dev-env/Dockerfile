FROM linuxcontainers/debian-slim:12
LABEL org.opencontainers.image.source=https://github.com/org-zpr/zpr-dev-tools
LABEL org.opencontainers.image.description="zpr build env DEB"

SHELL ["/bin/bash", "-c"]

WORKDIR /opt

RUN apt-get -y update \
&& apt-get install -y wget curl build-essential git pkg-config libssl-dev libpcap-dev \
&& apt autoremove


# Cap'n Proto
RUN apt-get install -y capnproto \
&& apt autoremove


# rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup.sh \
&& /bin/sh ./rustup.sh --default-toolchain stable -y


# valkey/redis
ARG VALKEY_VERSION=7.2.11
RUN wget -O "valkey-${VALKEY_VERSION}.tar.gz" "https://github.com/valkey-io/valkey/archive/refs/tags/${VALKEY_VERSION}.tar.gz" \
&& tar xf "valkey-${VALKEY_VERSION}.tar.gz" \
&& cd "valkey-${VALKEY_VERSION}" \
&& make && make install \
&& cd /opt \
&& rm -rf "valkey-${VALKEY_VERSION}" && rm "valkey-${VALKEY_VERSION}.tar.gz"


ENV PATH="$PATH:/root/.cargo/bin"
