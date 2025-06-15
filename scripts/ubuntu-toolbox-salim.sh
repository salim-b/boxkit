#!/bin/sh

# set env vars
export DEBIAN_FRONTEND=noninteractive

# symlink distrobox shims
./distrobox-shims.sh

# add additional APT package sources
curl --location \
     --output-dir /etc/apt/trusted.gpg.d \
     --remote-name \
     --silent \
     https://rig.r-pkg.org/deb/rig.gpg
echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list

# install TinyTeX's dummy DEB package to avoid `texlive-*` packages being automatically installed, cf. https://yihui.org/tinytex/faq/#faq-7
curl --silent --location "https://github.com/rstudio/tinytex-releases/releases/download/daily/texlive-local.deb" \
    && apt-get install --assume-yes --no-install-recommends ./texlive-local.deb \
    && rm texlive-local.deb

# install/update packages via APT
apt-get update && apt-get upgrade
grep --invert-match '^#' ./ubuntu-toolbox-salim.packages | xargs apt-get install --assume-yes

# install R
rig add release

# install [deb-get](https://github.com/wimpysworld/deb-get)
curl --location --silent https://api.github.com/repos/wimpysworld/deb-get/releases/latest \
  | yq --input-format=json --unwrapScalar=true '.assets[] | select(.name | test("^deb-get_.*_all\\.deb$")).browser_download_url' \
  | xargs --max-args=1 curl --location --output-dir /tmp --remote-name --silent \
  && apt-get install --assume-yes /tmp/deb-get_*.deb \
  && rm /tmp/deb-get_*.deb

# install additional packages via deb-get
deb-get install pandoc quarto rstudio

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

# set configuration to be executed at container runtime
# shellcheck disable=SC2016
echo 'export R_LIBS_USER="$HOME/.local/lib/r/%p-library/%v"' > /etc/profile.d/user_config.sh

# restore env vars
unset -v DEBIAN_FRONTEND
