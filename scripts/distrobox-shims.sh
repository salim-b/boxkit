#!/bin/sh

[ ! -e /usr/bin/sh ] && ln -fs /bin/sh /usr/bin/sh
ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker
ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak
ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman
ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree
ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open

# tools installed via Homebrew on the host (inside the container, `(/var)/home/homebrew` is unavailable)
ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/cu
ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/container-use
