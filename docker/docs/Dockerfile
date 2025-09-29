FROM pandoc/latex:3.7-ubuntu
LABEL org.opencontainers.image.source=https://github.com/org-zpr/zpr-docs
LABEL org.opencontainers.image.description="Documentation build container (Ubuntu base)"
LABEL org.opencontainers.image.version="2.0.0"

SHELL ["/bin/bash", "-c"]

RUN apt-get -y update && apt-get install -y git make && apt-get -y autopurge

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
