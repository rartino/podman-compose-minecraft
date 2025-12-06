FROM ubuntu:24.04 AS init_stage

WORKDIR /opt

ENV DEBIAN_FRONTEND noninteractive
ARG APT_PROXY=http://host.containers.internal:3142
RUN echo "Acquire::http::Proxy \"$APT_PROXY\";" > /etc/apt/apt.conf.d/00proxy && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/00proxy && \
    apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y wget apt-transport-https gnupg software-properties-common locales openjdk-21-jre-headless openjdk-21-jdk-headless git && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen && \
    /usr/sbin/useradd -s /bin/bash -d /minecraft -m minecraft && \
    apt-get clean all

FROM init_stage AS update_stage

RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get clean all

USER minecraft
WORKDIR /minecraft/server

CMD ["bash", "/opt/minecraft/startup.sh"]
