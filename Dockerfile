FROM armhf/debian:stretch-slim

ENV DEBIAN_FRONTEND=noninteractive

COPY qemu-arm-static /usr/bin

# upgrade and install all the libs zway needs ourself in one go
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y wget sharutils tzdata gawk libc-ares2 libavahi-compat-libdnssd-dev libarchive-dev curl libcurl3

WORKDIR /opt
RUN curl -O http://razberry.z-wave.me/z-way-server/z-way-server-RaspberryPiXTools-v2.3.8.tgz
RUN tar -zxvf z-way-server-RaspberryPiXTools-v2.3.8.tgz && rm z-way-server-RaspberryPiXTools-v2.3.8.tgz

RUN mkdir -p /etc/z-way/ && echo "v2.3.8" > /etc/z-way/VERSION && echo "razberry" > /etc/z-way/box_type

#COPY config.xml /opt/z-way-server/

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/z-way-server/libs

RUN rm /usr/bin/qemu-arm-static

WORKDIR /opt/z-way-server

CMD ["/opt/z-way-server/z-way-server"]

VOLUME /opt/z-way-server/config

EXPOSE 8083

HEALTHCHECK CMD curl --fail http://localhost:8083/ || exit 1
