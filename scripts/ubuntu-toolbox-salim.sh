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

# restore env vars
unset -v DEBIAN_FRONTEND
