FROM linuxcontainers/debian-slim:12
LABEL org.opencontainers.image.source=https://github.com/org-zpr/zpr-dev-tools
LABEL org.opencontainers.image.description="Documentation build env DEB"
LABEL org.opencontainers.image.version="0.0.1"

RUN apt-get -y update \
&& apt-get install -y git \
&& apt autoremove

RUN apt -y install pandoc texlive
