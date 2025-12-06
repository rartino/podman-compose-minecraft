build:
	podman-compose pull
	podman-compose build
	podman-compose run --user root minecraft bash -c 'cd /root/minecraft/build && wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && java -jar BuildTools.jar && cp spigot-*.jar /opt/minecraft/. && LATEST=$(cd /opt/minecraft; ls spigot-* | sort --version-sort | tail -n 1) && ln -s $LATEST /opt/minecraft/spigot.jar'
	echo -e '#!/bin/bash\nexec java -Xmx14G -Xms2G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC -DGeyser.PrintSecureChatInformation=false -DGeyserSkinManager.ForceShowSkins=false -jar /opt/minecraft/spigot.jar --nogui' > container-files/minecraft/startup.sh
	chmod +x container-files/minecraft/startup.sh
	podman-compose run --user root minecraft bash -c 'chown -R minecraft:minecraft /minecraft'
	podman-compose run minecraft bash -c "mkdir -p ~/server/plugins"
	podman-compose run minecraft bash -c "cd ~/server/plugins && wget 'https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot' -O Geyser-Spigot.jar"	
	podman-compose run minecraft bash -c "cd ~/server/plugins && wget 'https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot' -O floodgate-spigot.jar"

update:
	podman build --no-cache --target update_stage .

up:
	@trap "podman-compose down" INT TERM; \
	podman-compose up

down:
	podman-compose down

