#!/bin/bash

# exit immediately if a cmd fails or a var is undefined
set -euo pipefail

# set env vars
export DEBIAN_FRONTEND=noninteractive

# add additional APT package sources
curl --location \
     --output-dir /etc/apt/trusted.gpg.d \
     --remote-name \
     --silent \
     https://rig.r-pkg.org/deb/rig.gpg
echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list

# update DEB packages via APT
apt-get update && apt-get upgrade --assume-yes

# install TinyTeX's dummy DEB package to avoid `texlive-*` packages being automatically installed, cf. https://yihui.org/tinytex/faq/#faq-7
curl --location \
     --remote-name \
     --silent \
     "https://github.com/rstudio/tinytex-releases/releases/download/daily/texlive-local.deb" \
  && apt-get install --assume-yes --no-install-recommends ./texlive-local.deb \
  && rm texlive-local.deb

# install additional DEB packages via APT
grep --invert-match '^#' ./ubuntu-toolbox-salim.packages | xargs apt-get install --assume-yes

# install additional snap packages
snap install chromium

# install R
rig add release

# install [deb-get](https://github.com/wimpysworld/deb-get)
curl --location --silent https://api.github.com/repos/wimpysworld/deb-get/releases/latest \
  | yq --input-format=json --unwrapScalar=true '.assets[] | select(.name | test("^deb-get_.+_all\\.deb$")).browser_download_url' \
  | xargs --max-args=1 curl --location --output-dir /tmp --remote-name --silent \
  && apt-get install --assume-yes /tmp/deb-get_*.deb \
  && rm /tmp/deb-get_*.deb

# install additional DEB packages via deb-get
deb-get update && deb-get install \
  goose \
  pandoc \
  quarto \
  rstudio

# remove APT cache
rm --force --recursive /var/lib/apt/lists/*

# set locale settings
## useful doc: https://manpages.debian.org/unstable/manpages/locale.7.en.html
locale-gen de_CH.UTF-8
update-locale \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_NUMERIC=de_CH.UTF-8 \
  LC_TIME=de_CH.UTF-8 \
  LC_MONETARY=de_CH.UTF-8 \
  LC_MESSAGES=POSIX \
  LC_PAPER=de_CH.UTF-8 \
  LC_ADDRESS=de_CH.UTF-8 \
  LC_TELEPHONE=de_CH.UTF-8 \
  LC_MEASUREMENT=de_CH.UTF-8

# install custom RStudio theme
mkdir --parents /etc/rstudio/themes
curl --location \
     --output-dir /etc/rstudio/themes \
     --remote-name \
     https://raw.githubusercontent.com/salim-b/rscodeio/interim-merge/inst/resources/rscodeio_tomorrow_night_bright.rstheme
chmod a+r /etc/rstudio/themes/*

# restore env vars
unset -v DEBIAN_FRONTEND
