FROM armhf/debian:stretch-slim

ENV DEBIAN_FRONTEND=noninteractive

COPY qemu-arm-static /usr/bin

# needed to autoate the zway installation
ENV BOXED yes
ENV INSTALL_DIR /opt

# upgrade and install all the libs zway needs ourself in one go
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y rpi-update \
 && apt-get install -y wget sharutils tzdata gawk libc-ares2 libavahi-compat-libdnssd-dev libarchive-dev curl libcurl3

# /etc/z-way/box_type will put the script into boxed mode - automated install
RUN mkdir -p /etc/z-way/ && touch /etc/z-way/box_type

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/z-way-server/libs

# stop all the systemd services, since we need to do this differently with docker
RUN apt-get install -y supervisor \
     && mkdir -p /var/log/supervisor
#/etc/init.d/mongoose stop \
# && /etc/init.d/z-way-server stop \&&
 #update-rc.d z-way-server remove \
 #&& update-rc.d mongoose remove \&&


COPY supervisor/supervisor_main.conf /etc/supervisor/conf.d/main.conf
COPY supervisor/mongoose.conf /etc/supervisor/conf.d/mongoose.conf
COPY supervisor/zway-server.conf /etc/supervisor/conf.d/zway-server.conf
COPY supervisor/zbw_connect.conf /etc/supervisor/conf.d/zbw_connect.conf

COPY zway_installer.sh /root/zway_installer.sh
COPY zbw_connect_start.sh /usr/local/bin/zbw_connect_start

RUN /root/zway_installer.sh

# disable the build-in startup scripts, since we use supervisord ...
RUN /etc/init.d/mongoose stop \
 && /etc/init.d/z-way-server stop \
 && /etc/init.d/zbw_connect stop \
 && update-rc.d mongoose remove \
 && update-rc.d z-way-server remove \
 && update-rc.d zbw_connect remove

ENTRYPOINT ["/usr/bin/supervisord", "-c"]
CMD ["/etc/supervisor/supervisord.conf"]

VOLUME /opt/z-way-server/config

EXPOSE 8083

HEALTHCHECK CMD curl --fail http://localhost:8083/ || exit 1
