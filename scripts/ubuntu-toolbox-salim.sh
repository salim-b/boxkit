#!/bin/sh

# set env vars
export DEBIAN_FRONTEND=noninteractive

# symlink distrobox shims
./distrobox-shims.sh

# add additional APT package sources
curl --location --silent --output /etc/apt/trusted.gpg.d/rig.gpg https://rig.r-pkg.org/deb/rig.gpg
sh -c 'echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list'

# update the container and install packages via APT
apt-get update && apt-get upgrade
grep -v '^#' ./ubuntu-toolbox-salim.packages | xargs apt-get install --assume-yes

# install R
rig add release

# install [deb-get](https://github.com/wimpysworld/deb-get)
curl --silent --location https://api.github.com/repos/wimpysworld/deb-get/releases/latest \
  | yq --input-format=json --unwrapScalar=true '.assets[] | select(.name | test("^deb-get_.*_all\\.deb$")).browser_download_url' \
  | wget --quiet --directory-prefix="/tmp" --input-file=- \
  && apt-get install --assume-yes /tmp/deb-get_*.deb \
  && rm /tmp/deb-get_*.deb

# install additional packages via deb-get
deb-get install pandoc quarto rstudio

# remove APT cache
rm -rf /var/lib/apt/lists/*

# set locale settings
## useful doc: https://www.ibm.com/docs/en/integration-bus/latest?topic=locales-changing-your-locale-linux-systems
update-locale \
  LANG=en_US.UTF-8 \
  LC_ADDRESS=de_CH.UTF-8 \
  LC_MEASUREMENT=de_CH.UTF-8 \
  LC_MESSAGES=POSIX \
  LC_MONETARY=de_CH.UTF-8 \
  LC_NUMERIC=de_CH.UTF-8 \
  LC_PAPER=de_CH.UTF-8 \
  LC_TELEPHONE=de_CH.UTF-8 \
  LC_TIME=de_CH.UTF-8
## we also need to overwrite the `LANG` env var
export LANG=en_US.UTF-8

# restore env vars
unset -v DEBIAN_FRONTEND
