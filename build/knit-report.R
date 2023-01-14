#!/usr/bin/env Rscript

library(docopt)
library(rmarkdown)

arguments <- "
Generate a report of container image's infomation.

Usage:
  knit-report.R <source_directory_name> <git_repo_name> <image_name> <output_dir>

Examples:
  ./build/knit-report.R -d tmp/imageid https://github.com/rocker-org/devcontainer-images imageid reports
" |>
  docopt::docopt()

template <- file.path("build/reports/template.Rmd")

git_repository <- arguments$git_repo_name
image_name <- arguments$image_name
output_dir <- arguments$output_dir

source_directory_name <- arguments$source_directory_name
inspect_file <- file.path(source_directory_name, "docker_inspect.json")
imagetotls_inspect_file <- file.path(source_directory_name, "imagetools_inspect.txt")
devcontainer_info_file <- file.path(source_directory_name, "devcontainer-info.txt")
apt_file <- file.path(source_directory_name, "apt_packages.tsv")
r_file <- file.path(source_directory_name, "r_packages.ssv")
pip_file <- file.path(source_directory_name, "pip_packages.ssv")
intermediates_dir <- source_directory_name

rmarkdown::render(
  input = template,
  intermediates_dir = intermediates_dir,
  output_dir = output_dir,
  output_file = paste0(arguments$image_name, ".md"),
  params = list(
    git_repository = git_repository,
    image_name = image_name,
    inspect_file = inspect_file,
    imagetotls_inspect_file = imagetotls_inspect_file,
    devcontainer_info_file = devcontainer_info_file,
    apt_file = apt_file,
    r_file = r_file,
    pip_file = pip_file
  )
)
