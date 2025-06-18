# shellcheck disable=SC2148

# env vars to be set at user session start
export R_LIBS_USER="$HOME/.local/lib/r/%p-library/%v"

# run TinyTeX and R install/update scripts
if [ -z "$R_INIT_DONE" ]; then
    export R_INIT_DONE=1
    install_tinytex.R
    install_rpkgs.R
fi
