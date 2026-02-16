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
echo 'deb http://rig.r-pkg.org/deb rig main' > /etc/apt/sources.list.d/rig.list

# update DEB packages via APT
apt-get update && apt-get upgrade --assume-yes

# install TinyTeX's dummy DEB package to avoid `texlive-*` packages being automatically installed, cf. https://yihui.org/tinytex/faq/#faq-7
curl --location \
     --remote-name \
     --silent \
     'https://github.com/rstudio/tinytex-releases/releases/download/daily/texlive-local.deb' \
  && apt-get install --assume-yes --no-install-recommends ./texlive-local.deb \
  && rm texlive-local.deb

# install additional DEB packages via APT
grep --invert-match '^#' ./ubuntu-toolbox-salim.packages | xargs apt-get install --assume-yes

# install Rust
mkdir -p /opt/rust \
  && curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
  && chmod -R a+w /opt/rust \
  && rustup component add \
    clippy \
    llvm-tools \
    miri \
    rust-analyzer \
    rust-src \
    rustfmt \
  && rustup default stable

# install R
rig add release

# install deb-get
curl --location --silent 'https://api.github.com/repos/wimpysworld/deb-get/releases/latest' \
  | yq --input-format=json --unwrapScalar=true '.assets[] | select(.name | test("^deb-get_.+_all\\.deb$")).browser_download_url' \
  | xargs --max-args=1 curl --location --remote-name --silent \
  && apt-get install --assume-yes ./deb-get_*.deb \
  && rm deb-get_*.deb

# install additional DEB packages via deb-get
deb-get update && deb-get install \
  goose \
  mise \
  pandoc \
  quarto \
  rstudio

# install dra
curl --location --silent 'https://api.github.com/repos/devmatteini/dra/releases/latest' \
  | yq -r '.assets[] | select(.name | test("dra_.*_amd64\.deb")) | .browser_download_url' \
  | xargs --max-args=1 curl --location --remote-name --silent \
  && apt-get install --assume-yes ./dra_*_amd64.deb

# install additional DEB packages downloaded via dra
## Ungoogled Chromium
## COMMENTED OUT since Ubuntu jammy doesn't include new enough dependencies
# dra download --select "ungoogled-chromium_*_amd64.deb" berkley4/ungoogled-chromium-debian \
#  && apt-get install ./ungoogled-chromium_*_amd64.deb
# dra download --select "ungoogled-chromium-driver_*_amd64.deb" berkley4/ungoogled-chromium-debian \
#  && apt-get install ./ungoogled-chromium-driver_*_amd64.deb
# ## we also need to install an AppArmor profile, cf. https://github.com/berkley4/ungoogled-chromium-debian#apparmor-profile-affects-ubuntu-2404-and-later
# curl --location \
#     --output-dir /etc/apparmor.d \
#     --remote-name \
#     --silent \
#     'https://raw.githubusercontent.com/berkley4/ungoogled-chromium-debian/refs/heads/unstable/debian/etc/apparmor.d/usr.bin.chrome'
# chmod 0644 /etc/apparmor.d/usr.bin.chrome

# install Google Chrome (while we can't use Ungoogled Chromium)
curl --location \
     --remote-name \
     --silent \
     "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
  && apt-get install --assume-yes ./google-chrome-stable_current_amd64.deb \
  && rm google-chrome-stable_current_amd64.deb

# install additional CLI tools via mise
mise use --global github:casey/just

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
