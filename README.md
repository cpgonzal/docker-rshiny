## Rshiny Dockerfile

This repository contains **Dockerfile** for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/dockerfile/cpgonzal/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).


### Base Docker Image

* [dockerhub/cpgonzal/docker-r](https://hub.docker.com/r/cpgonzal/docker-r/)

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/dockerfile/cpgonzal/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull cpgonzal/docker-rshiny`

   (alternatively, you can build an image from Dockerfile: `docker build -t="cpgonzal/docker-rshiny" github.com/cpgonzal/docker-rshiny`)


### Usage (recommended using with persistent shared directories)

#### Run `cpgonzal/docker-rshiny` container with persistent shared directories 

    # ONLY THE FIRST TIME TO INSTALL REQUIRED R LIBRARIES
    docker run --rm --name rshiny-dock -e USERID=`id -u $USER` -v <data-dir>:/data -v <libraries-dir>:/libraries cpgonzal/docker-rshiny &
    docker exec -it -u rshiny rshiny-dock /bin/bash /usr/local/lib/R/etc/install_pkgs.sh
    docker stop rshiny-dock

    # NEXT TIME 
    docker run --rm --name rshiny-doc -p 3838:3838 -e USERID=`id -u $USER` -e PORT=3838 -v <data-dir>:/data -v <libraries-dir>:/libraries cpgonzal/docker-rshiny &
    # open http://<ip-address>:3838
    docker inspect -f '{{.Name}} - {{.NetworkSettings.IPAddress }}' $(docker ps -aq)  
