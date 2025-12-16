FROM pandoc/latex:3.7-ubuntu
LABEL org.opencontainers.image.source=https://github.com/org-zpr/zpr-docs
LABEL org.opencontainers.image.description="Documentation build container (Ubuntu base)"
LABEL org.opencontainers.image.version="2.0.0"

SHELL ["/bin/bash", "-c"]

#RUN apt-get -y update && apt-get install -y git make npm && apt-get -y autopurge
RUN apt-get -y update \
	 && apt-get install -y git make npm software-properties-common plantuml \
	 && apt-get -y autopurge
ENV PUPPETEER_CACHE_DIR=/usr/local/share/puppeteer/.cache/
RUN npm install -g @mermaid-js/mermaid-cli@latest && npm -g rebuild puppeteer && npx puppeteer browsers install chrome-headless-shell --install-deps

ADD ./puppeteer-config.json /etc/puppeteer-conf.json

ENV PANDOC_DATA_HOME=/usr/local/share/pandoc
ENV PANDOC_FILTERS_DIR=${PANDOC_DATA_HOME}/filters
RUN <<EOF
mkdir -p ${PANDOC_FILTERS_DIR}
wget -q -P ${PANDOC_FILTERS_DIR} https://raw.githubusercontent.com/pandoc-ext/diagram/refs/tags/v1.2.0/_extensions/diagram/diagram.lua
chmod +x ${PANDOC_FILTERS_DIR}/diagram.lua
EOF

ENTRYPOINT []

RUN <<EOF
tlmgr update --self && tlmgr install titlesec tex-gyre
# Change the font directory away from a user directory to prevent them being rebuilt
texconfig font vardir /opt/texlive/texdir/texmf-var/fonts
# Build the missing fonts
mktexpk --mfmode / --bdpi 600 --mag 1+0/600 --dpi 600 ectt1095
mktexpk --mfmode / --bdpi 600 --mag 1+0/600 --dpi 600 tctt1095
# Rebuild the LS-R
texhash
updmap-sys
TERM=dumb luaotfload-tool --update
chmod -R o+w /opt/texlive/texdir/texmf-var
fc-cache -fsv
EOF
