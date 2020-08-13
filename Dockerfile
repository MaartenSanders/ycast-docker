#
# Docker Buildfile for the ycast-docker container based on alpine linux - about 41.4MB
# put dockerfile and bootstrap.sh in same directory
# usage: docker build --compress -f ycast-dockerfile-v9 -t yourrepro/ycast-docker:v9 .
#
FROM alpine:latest

#
# Variables
# YC_VERSION version of ycast software
# YC_STATIONS path an name of the indiviudual stations.yml e.g. /ycast/stations/stations.yml
# YC_DEBUG turn ON or OFF debug output of ycast server else only start /bin/sh
# YC_PORT port ycast server listens to, e.g. 80
#
ENV YC_VERSION 1.0.0
ENV YC_STATIONS /opt/ycast/stations/stations.yml
ENV YC_DEBUG OFF
ENV YC_PORT 80

#
# Upgrade alpine Linux, install python3 and dependencies for pillow - alpine does not use glibc
# pip install needed modules for ycast
# make /opt/ycast Directory, delete unneeded packages, jpeg-dev still needed
# download ycast tar.gz and extract it in ycast Directory
# delete unneeded stuff
#
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk add --no-cache py3-pip && \
    apk add --no-cache zlib-dev && \
    apk add --no-cache jpeg-dev && \
    apk add --no-cache build-base && \
    apk add --no-cache python3-dev && \
    pip3 install --no-cache-dir requests && \
    pip3 install --no-cache-dir flask && \
    pip3 install --no-cache-dir PyYAML && \
    pip3 install --no-cache-dir Pillow  && \
    mkdir /opt/ycast && \
    apk del --no-cache python3-dev && \
    apk del --no-cache build-base && \
    apk del --no-cache zlib-dev && \
    apk add --no-cache curl && \
    curl -L https://github.com/milaq/YCast/archive/$YC_VERSION.tar.gz \
    | tar xvzC /opt/ycast && \
    apk del --no-cache curl && \
#    pip3 uninstall --no-cache-dir -y setuptools && \
    pip3 uninstall --no-cache-dir -y py3-pip && \
    pip3 uninstall --no-cache-dir -y setuptools && \
    find /usr/lib -name \*.pyc -exec rm -f {} \; && \
#    find /usr/share/terminfo -type f -not -name xterm -exec rm -f {} \; && \
    find /usr/lib -type f -name \*.exe -exec rm -f {} \; 

#
# Set Workdirectory on ycast folder
#
WORKDIR /opt/ycast/YCast-$YC_VERSION

#
# Copy bootstrap.sh to /opt
#
COPY bootstrap.sh /opt

#
# Docker Container should be listening for AVR on port 80
#
EXPOSE $YC_PORT/tcp

#
# Start bootstrap on Container start
#
RUN ["chmod", "+x", "/opt/bootstrap.sh"]
ENTRYPOINT ["/opt/bootstrap.sh"]

