ARG VARIANT=4
ARG BASE_IMAGE=rocker/r-ver
FROM ${BASE_IMAGE}:${VARIANT}

RUN useradd -s /bin/bash -m rstudio \
    usermod -a -G staff rstudio
