#!/usr/bin/env Rscript

# define relevant vars
tinytex_dir <- "~/.local/lib/tinytex"
tinytex_bundle <- "TinyTeX"
latex_pkgs <- c("nowidow",
                "tocbibind")

# ensure `~/.local/bin` exists so the TinyTex installer picks it up
if (!dir.exists("~/.local/bin")) {
  dir.create(path = "~/.local/bin",
             recursive = TRUE)
}

# install tinytex package if not already done
if (!nzchar(system.file(package = "tinytex"))) {
  install.packages(pkgs = "tinytex",
                   repos = "https://cloud.r-project.org")
}

# install the LaTeX distro TinyTeX if not already done or re-install if tlmgr is older than 3 months
## install for the first time...
if (!file.exists(file.path(tinytex_dir, ".tinytex"))) {
  tinytex::install_tinytex(force = TRUE,
                           dir = tinytex_dir,
                           bundle = tinytex_bundle,
                           extra_packages = latex_pkgs)
} else {
  ## ...or register and reinstall if necessary
  if (!nzchar(tinytex::tinytex_root(error = FALSE))) {
    tinytex::use_tinytex(from = tinytex_dir)
  }
  if (nzchar(tinytex::tinytex_root(error = FALSE)) && (as.Date(file.mtime(file.path(tinytex_dir, ".tinytex"))) + 90L) < Sys.Date()) {
    tinytex::reinstall_tinytex(bundle = tinytex_bundle)
  }
}

