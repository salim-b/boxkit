#!/bin/sh

# set env vars
export DEBIAN_FRONTEND=noninteractive

# symlink distrobox shims
./distrobox-shims.sh

# update the container and install packages via APT
apt-get update && apt-get upgrade
grep -v '^#' ./ubuntu-toolbox-salim.packages | xargs apt-get install --assume-yes

# install [deb-get](https://github.com/wimpysworld/deb-get)
curl --silent --location https://api.github.com/repos/wimpysworld/deb-get/releases/latest \
  | yq --input-format=json --unwrapScalar=true '.assets[] | select(.name | test("^deb-get_.*_all\\.deb$")).browser_download_url' \
  | wget --quiet --directory-prefix="/tmp" --input-file=- \
  && apt-get install --assume-yes /tmp/deb-get_*.deb \
  && rm /tmp/deb-get_*.deb \
  && rm -rf /var/lib/apt/lists/*

# install additional packages via deb-get
deb-get install pandoc quarto

# restore env vars
unset -v DEBIAN_FRONTEND
