# shellcheck disable=SC2148

# env vars to be set at user session start
export R_LIBS_USER="${HOME}/.local/lib/r/%p-library/%v"
## make sure container-internal executables have precendence over the host's executables
export PATH="/opt/mise/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:${PATH}"

