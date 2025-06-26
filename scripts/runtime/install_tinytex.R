#!/usr/bin/env Rscript

# ensure `~/.local/bin` exists so the TinyTex installer picks it up
if (!dir.exists("~/.local/bin")) {
  dir.create(path = "~/.local/bin",
             recursive = TRUE)
}

# install tinytex package if not already done
if (!nzchar(system.file(package = "tinytex"))) {
  install.packages(pkgs = "tinytex",
                   dependencies = TRUE)
}

# install the LaTeX distro TinyTeX if not already done or re-install if tlmgr is older than 2 months
TINYTEX_DIR <- "~/.local/lib/tinytex"

if (!nzchar(tinytex::tinytex_root(error = FALSE))) {
  if (file.exists(file.path(TINYTEX_DIR, ".tinytex"))) {
    tinytex::use_tinytex(from = TINYTEX_DIR)
  } else {
    tinytex::install_tinytex(force = TRUE,
                             dir = TINYTEX_DIR,
                             bundle = "TinyTeX")
  }
} else if ((tinytex::tlmgr_version(format = "list")$tlmgr + 60L) < Sys.Date()) {
  tinytex::reinstall_tinytex(bundle = "TinyTeX")
}
