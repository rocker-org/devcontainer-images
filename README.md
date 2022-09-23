# devcontainer images for R

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Build and push images](https://github.com/rocker-org/r-devcontainer-images/actions/workflows/build.yml/badge.svg)](https://github.com/rocker-org/r-devcontainer-images/actions/workflows/build.yml)

<!-- badges: end -->

devcontainer images for R buildable with [the devcontainer cli](https://github.com/devcontainers/cli).

Heavily under development.

## Development

[Visual Studio Code Remote - Containers](https://containers.dev/supporting#remote-containers) can be used.

Build the container with the make command.

```sh
SRC_NAME=r-ver IMAGE_NAME=tidyverse VARIANT=4.2 make devcontainer
```
