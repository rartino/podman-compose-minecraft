build:
	podman-compose pull
	podman-compose build
	podman-compose run --user root minecraft bash -c 'cd /root/minecraft/build && wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && java -jar BuildTools.jar'
	echo -e '#!/bin/bash\nexec java -Xmx14G -Xms2G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC -DGeyser.PrintSecureChatInformation=false -DGeyserSkinManager.ForceShowSkins=false -jar /opt/minecraft/spigot.jar --nogui' > container-files/server/startup.sh
	chmod +x container-files/server/startup.sh

update:
	podman build --no-cache --target update_stage .
