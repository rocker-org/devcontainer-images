ARG VARIANT=4
ARG BASE_IMAGE=rocker/r-ver
FROM ${BASE_IMAGE}:${VARIANT}

RUN /rocker_scripts/default_user.sh \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
        python3-pip \
        libcurl4-openssl-dev \
        libxml2-dev \
        libssl-dev \
        libfontconfig1-dev \
        libcairo2-dev \
    && apt-get autoremove -y && apt-get clean -y \
    && python3 -m pip --no-cache-dir install \
        radian \
    && install2.r --error --skipinstalled --ncpus -1 \
        languageserver \
        httpgd \
    && rm -rf /tmp/downloaded_packages \
    && strip /usr/local/lib/R/site-library/*/libs/*.so
