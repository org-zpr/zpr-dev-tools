FROM linuxcontainers/debian-slim:12
LABEL org.opencontainers.image.source=https://github.com/org-zpr/zpr-dev-tools
LABEL org.opencontainers.image.description="Documentation build env DEB"
LABEL org.opencontainers.image.version="1.0.0"

RUN apt-get -y update
RUN apt-get install -y git pandoc texlive make
RUN apt-get autoremove
