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
ARG UPDATE_STAMP=0

RUN echo "$UPDATE_STAMP" >/dev/null && \
    apt-get update && apt-get -y dist-upgrade && \
    apt-get clean all

USER minecraft
WORKDIR /minecraft/server

FROM update_stage AS build_stage
ARG BUILD_STAMP=0

RUN echo "$BUILD_STAMP" >/dev/null && \
    mkdir -p ~/build && \
    cd ~/build && \
    wget 'https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot' -O Geyser-Spigot.jar && \
    jar xf Geyser-Spigot.jar plugin.yml && VERSION=$(cat ./plugin.yml | awk -F': | |-' '$1 == "version" {print$2}') && rm plugin.yml && \
    mv Geyser-Spigot.jar Geyser-Spigot-$VERSION.jar && \
    wget 'https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot' -O floodgate-spigot.jar && \
    jar xf floodgate-spigot.jar plugin.yml && cat plugin.yml && VERSION=$(cat ./plugin.yml | awk -F': | |-' '$1 == "version" {print$2}') && rm plugin.yml && \
    mv floodgate-spigot.jar floodgate-spigot-$VERSION.jar && \
    wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && \
    java -jar BuildTools.jar

USER root
RUN echo "$BUILD_STAMP" >/dev/null && \
    mkdir -p /opt/minecraft && \
    cp /minecraft/build/spigot-*.jar /minecraft/build/Geyser-Spigot-*.jar /minecraft/build/floodgate-spigot-*.jar /opt/minecraft/.
COPY helpers/startup.sh /opt/minecraft/startup.sh
USER minecraft

CMD ["bash", "/opt/minecraft/startup.sh"]
