ARG VARIANT=4
ARG BASE_IMAGE=rocker/r-ver
FROM ${BASE_IMAGE}:${VARIANT}

RUN /rocker_scripts/default_user.sh \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
        python3-pip \
        libgit2-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libssl-dev \
        libfontconfig1-dev \
        libcairo2-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfreetype6-dev \
        libpng-dev \
        libtiff5-dev \
        libjpeg-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip --no-cache-dir install \
        radian \
    && install2.r --error --skipinstalled --ncpus -1 \
        devtools \
        httpgd \
        languageserver \
    && rm -rf /tmp/downloaded_packages \
    && strip /usr/local/lib/R/site-library/*/libs/*.so \
    && R -q -e 'remotes::install_github("ManuelHentschel/vscDebugger@*release", dependencies = FALSE)'

COPY --chown=rstudio:rstudio assets/rstudio-prefs.json /home/rstudio/.config/rstudio/
