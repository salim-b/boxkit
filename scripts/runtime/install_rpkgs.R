#!/usr/bin/env Rscript
#
# NOTES
#
# - `install.packages()` with a P3M binary `repos` URL results in corrupted package installations due to surplus package name subdirectories inside the library
#   path; the underlying reason is still unknown to us; the issue only occurs in Distrobox containers and is likely related to some unwanted host-container
#   interaction; `pak::pkg_install()` is not affected by this issue, but `remotes::install_*()` is when it install dependencies for which it relies on
#   `install.packages()`.
#
#   The underlying issue is with `R CMD INSTALL` (invoked by `install.packages()`). A concise way to reproduce the issue and inspect the system calls made is:
#
#   ```sh
#   mkdir testlib
#   curl --location --remote-name --header "User-Agent: R/4.5.1 R (4.5.1 x86_64-pc-linux-gnu x86_64 linux-gnu)" https://p3m.dev/cran/__linux__/noble/latest/src/contrib/checkmate_2.3.2.tar.gz
#   strace -f -e trace=mkdir,rename R CMD INSTALL -l ~/testlib checkmate_2.3.2.tar.gz 2>&1 | tee install-strace.log
#   ```
#
#   LLM conversation trying to debug this (without solution): https://chatgpt.com/share/688eb500-66e0-8006-b704-666a2d85ee3e

# install/update commonly used R packages from CRAN
## install pak via base R if necessary
if (!nzchar(system.file(package = "pak"))) {
  install.packages(pkgs = "pak",
                   repos = "https://cloud.r-project.org")
}

## define CRAN pkgs
pkgs_cran <- c(
  "anesrake",
  "anytime",
  "archive",
  "arrow",
  "asciicast",
  "assertr",
  "available",
  "bench",
  "BFS",
  "blastula",
  "blogdown",
  "bookdown",
  "brio",
  "broom",
  "checkmate",
  "cli",
  "clipr",
  "clock",
  "commonmark",
  "constructive",
  "covr",
  "crayon",
  "crosstalk",
  "crul",
  "curl",
  "daff",
  "datapasta",
  "DBI",
  "deeplr",
  "desc",
  "DescTools",
  "devtools",
  "DiagrammeR",
  "DiagrammeRsvg",
  "dials",
  "diffobj",
  "diffviewer",
  "digest",
  "dm",
  "dplyr",
  "dqrng",
  "DT",
  "duckdb",
  "forcats",
  "fs",
  "gargle",
  "gert", # needs to be installed from source to resolve the "failed to start SSH session: Unable to ask for ssh-userauth service" error
  "ggeffects",
  "ggforce",
  "ggiraph",
  "ggplot2",
  "ggstream",
  "gh",
  "git2r",
  "gitlabr",
  "glue",
  "googledrive",
  "googlesheets4",
  "graphql",
  "gt",
  "gtsummary",
  "haven",
  "heck",
  "hexSticker",
  "hms",
  "htmltools",
  "htmlwidgets",
  "httr2",
  "imager",
  "infer",
  "ISOcodes",
  "janitor",
  "jsonlite",
  "kableExtra",
  "katex",
  "keyring",
  "knitr",
  "komaletter",
  "labelled",
  "languageserver",
  "learnr",
  "lifecycle",
#  "lintr", # dev version in use
  "listviewer",
  "lobstr",
  "lubridate",
  "magick",
  "magrittr",
  "miniUI",
  "mirt",
  "modeldata",
  "modelr",
  "mongolite",
  "oai",
  "openssl",
  "pak",
  "paletteer",
  "pander",
  "parsedate",
  "parsnip",
  "pins",
  "pkgbuild",
  "pkgcache",
  "pkgdepends",
  "pkgdown",
  "pkgload",
  "pkgsearch",
#  "plotly", # dev version in use
  "plumber",
  "prettycode",
  "prettyunits",
  "purrr",
  "qpdf",
  "qs",
  "quarto",
  "R6",
  "ragg",
  "rcmdcheck",
  "RColorBrewer",
  "Rcpp",
  "RcppTOML",
  "RCurl",
  "readODS",
  "readr",
  "readxl",
  "recipes",
  "remotes",
  "renv",
  "reprex",
  "reticulate",
  "revealjs",
  "rex",
  "rio",
  "rJava",
  "rlang",
  "rmarkdown",
#  "roxygen2", # dev version in use
  "RPostgres",
#  "rprojroot", # dev version in use
  "rsample",
  "rsconnect",
  "RSelenium",
  "rstudioapi",
  "rsvg",
  "rvest",
  "s2",
  "s3fs",
  "servr",
  "sessioninfo",
  "sf",
  "shiny",
  "showtext",
  "skimr",
  "staplr",
  "stringdist",
  "stringi",
  "stringr",
  "styler",
  "swissparl",
  "testthat",
  "tibble",
  "tidyr",
  "tidyRSS",
  "tidyselect",
  "tidytext",
  "tidyverse",
  "tiff",
  "tinkr",
  "tokenizers",
  "tune",
  "tweenr",
  "uaparserjs",
  "units",
  "urltools",
  "usethis",
  "uuid",
  "V8",
  "vctrs",
  "viridis",
  "visdat",
  "vroom",
  "webshot2",
  "whoami",
  "widyr",
  "withr",
  "workflows",
  "writexl",
  "xfun",
  "xml2",
  "xopen",
  "xslt",
  "yaml",
  "yardstick",
  "yesno",
  "zip"
)

## install/update CRAN pkgs
pak::pkg_install(pkg = pkgs_cran,
                 ask = FALSE)

# install/update packages not (yet/anymore) on CRAN directly from Git forges
## third-party packages
pak::pkg_install(pkg = c("github::mattflor/chorddiag",
                         "github::konradedgar/extraInserts",
                         "github::nx10/httpgd",
                         "github::hrbrmstr/qrencoder",
                         "github::LudvigOlsen/splitChunk",
                         "github::politanch/swissdd",
                         "github::ManuelHentschel/vscDebugger"),
                 ask = FALSE)
## own packages
### TODO: use `pak::pkg_install()` once https://github.com/r-lib/pak/issues/796 is resolved
remotes::install_gitlab(repo = "salim_b/r/pkgs/salim",
                        dependencies = TRUE,
                        upgrade = FALSE)
salim::update_rpkgs()
salim::update_salims_pkgs()
salim::update_zdaarau_pkgs(pkgs = c("rdb.report", "fokus", "swissevote"))
remotes::install_gitlab(repo = "zdaarau/rpkgs/rdb@pg",
                        dependencies = TRUE,
                        upgrade = FALSE)

## third-party pkgs with notable (own) unmerged PRs for which we maintain an "interim" branch
pak::pkg_install(pkg = c("github::salim-b/lintr", # TODO: switch to CRAN version once lintr 3.2.1+ is released
                         "github::salim-b/plotly.R@interim-merge",
                         "github::salim-b/roxygen2@interim-merge", # switch to `r-lib/roxygen2` once https://github.com/r-lib/roxygen2/pull/1712 is merged
                         "github::salim-b/rprojroot@interim-merge",
                         "github::salim-b/rscodeio@interim-merge"),
                 ask = FALSE)
