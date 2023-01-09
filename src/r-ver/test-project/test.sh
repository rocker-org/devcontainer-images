#!/usr/bin/env bash

set -e

devcontainer-info

cd "$(dirname "${BASH_SOURCE[0]}")"

# Run the test
R -q -e "rmarkdown::render('hello.Rmd', output_file = 'hello.md')"
cat hello.md
