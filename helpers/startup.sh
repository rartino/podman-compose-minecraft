#!/bin/bash

# Keep a backup of all versions we have been running, to make it possible to rollback
mkdir -p jars
LATEST_SPIGOT=$(cd /opt/minecraft; ls spigot-* | sort --version-sort | tail -n 1)
LATEST_GEYSER=$(cd /opt/minecraft; ls Geyser-Spigot-* | sort --version-sort | tail -n 1)
LATEST_FLOODGATE=$(cd /opt/minecraft; ls floodgate-* | sort --version-sort | tail -n 1)
cp "/opt/minecraft/$LATEST_SPIGOT" "/opt/minecraft/$LATEST_GEYSER" "/opt/minecraft/$LATEST_FLOODGATE" jars/.

ln -snf "jars/$LATEST_SPIGOT" spigot.jar

mkdir -p plugins
ln -snf "../jars/$LATEST_GEYSER" plugins/Geyser-Spigot.jar
ln -snf "../jars/$LATEST_FLOODGATE" plugins/floodgate.jar

exec java -Xmx14G -Xms2G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC -DGeyser.PrintSecureChatInformation=false -DGeyserSkinManager.ForceShowSkins=false -jar ./spigot.jar --nogui
