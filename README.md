# devcontainer images for R

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Build and push images](https://github.com/rocker-org/r-devcontainer-images/actions/workflows/build.yml/badge.svg)](https://github.com/rocker-org/r-devcontainer-images/actions/workflows/build.yml)

<!-- badges: end -->

devcontainer images for R buildable with [the devcontainer cli](https://github.com/devcontainers/cli).

Heavily under development.

## Development

[Visual Studio Code Remote - Containers](https://containers.dev/supporting#remote-containers) can be used.

It is configured to create temporary files with rewritten variables based on the files in [the `src` directory](src/)
and build the containers from the temporary definition files.

The variables are written in [`build/args.json`](build/args.json).

Creating files to build containers and invoking container build commands can be done via [Makefile](Makefile).

Create definition files to build the container with the settings described
in `."r-ver"."r-ver".variants."4.2"` in `build/args.json` as follows:

```sh
SRC_NAME=r-ver IMAGE_NAME=r-ver VARIANT=4.2 make configfiles
```

Build the container with the settings described
in `."rstudio"."tidyverse".variants."4.2"` in `build/args.json` as follows:


```sh
SRC_NAME=rstudio IMAGE_NAME=tidyverse VARIANT=4.2 make devcontainer
```
