## Adapted from https://hub.docker.com/r/rocker/shiny
FROM cpgonzal/docker-r

# Dockerfile author / maintainer 
MAINTAINER Carlos P. <cpgonzal@gmail.com> 


#####################################################################
#shiny
#####################################################################
RUN apt-get update && apt-get install -y \
    sudo \
    wget \ 
    file \
    git \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/ \
 && git config --system credential.helper 'cache --timeout=3600' \
  && git config --system push.default simple \
  ## Set up S6 init system
  && wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && rm -rf /tmp/s6-overlay-amd64.tar.gz \
  # Download and install shiny server
  && wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" \
  && VERSION=$(cat version.txt)  \
  && wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb \
  && gdebi -n ss-latest.deb \
  && rm -f version.txt ss-lates \
  ## And some nice R packages for publishing-related stuff 
  && echo ". /etc/environment" >> /usr/local/lib/R/etc/install_pkgs.sh \ 
  && echo "install2.r --error \\" >> /usr/local/lib/R/etc/install_pkgs.sh \
  && echo "  --libloc \$LIBS_ROOT \\" >> /usr/local/lib/R/etc/install_pkgs.sh \
  && echo "  --repos 'http://www.bioconductor.org/packages/release/bioc' \\" >> /usr/local/lib/R/etc/install_pkgs.sh \
  && echo "  --repos \$MRAN \\" >> /usr/local/lib/R/etc/install_pkgs.sh \
  && echo "  --deps TRUE \\" >> /usr/local/lib/R/etc/install_pkgs.sh \
  && echo "  shiny rmarkdown" >> /usr/local/lib/R/etc/install_pkgs.sh \
  && echo "cp -R \$LIBS_ROOT/shiny/examples \$DATA_ROOT/shiny-server/" >> /usr/local/lib/R/etc/install_pkgs.sh \
  && echo "cp -R /opt/shiny-server/samples/* \$DATA_ROOT/shiny-server/" >> /usr/local/lib/R/etc/install_pkgs.sh 


COPY shiny-server.sh /etc/cont-init.d/conf
EXPOSE 3838
ENTRYPOINT ["/init"]


