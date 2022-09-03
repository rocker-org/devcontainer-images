# devcontainer images for R

devcontainer images for R buildable with [the devcontainer cli](https://github.com/devcontainers/cli).

Heavily under development.

## Development

[Visual Studio Code Remote - Containers](https://containers.dev/supporting#remote-containers) can be used.

Build the container with the make command.

```sh
SRC_NAME=r-ver SRC_NAME=tidyverse VARIANT=4.2 DEVCON_BUILD_OPTION=--push make devcontainer
```
