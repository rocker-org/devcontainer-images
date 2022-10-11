ARG VARIANT=4
ARG BASE_IMAGE=rocker/rstudio
FROM ${BASE_IMAGE}:${VARIANT}

COPY --chown=rstudio:rstudio assets/rstudio-prefs.json /home/rstudio/.config/rstudio/
