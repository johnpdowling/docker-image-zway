FROM armhf/debian:stretch-slim

ENV DEBIAN_FRONTEND=noninteractive

COPY qemu-arm-static /usr/bin

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y wget sharutils tzdata gawk libc-ares2 libavahi-compat-libdnssd-dev libarchive-dev curl libcurl3

#COPY z-way-server-RaspberryPiXTools-v2.3.8.tgz /opt
WORKDIR /opt
RUN curl -O https://storage.z-wave.me/z-way-server/z-way-server-RaspberryPiXTools-v2.3.8.tgz
RUN tar -xvf z-way-server-RaspberryPiXTools-v2.3.8.tgz && rm z-way-server-RaspberryPiXTools-v2.3.8.tgz

#COPY config.xml /opt/z-way-server/

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/z-way-server/libs

RUN rm /usr/bin/qemu-arm-static

WORKDIR /opt/z-way-server

CMD ["/opt/z-way-server/z-way-server"]

VOLUME /opt/z-way-server/config

EXPOSE 8083

HEALTHCHECK CMD curl --fail http://localhost:8083/ || exit 1
