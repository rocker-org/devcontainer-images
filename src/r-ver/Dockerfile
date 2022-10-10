ARG VARIANT=4
ARG BASE_IMAGE=rocker/r-ver
FROM ${BASE_IMAGE}:${VARIANT}

RUN /rocker_scripts/default_user.sh

COPY --chown=rstudio:rstudio assets/rstudio-prefs.json /home/rstudio/.config/rstudio/
