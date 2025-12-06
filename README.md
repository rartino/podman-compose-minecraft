# podman-compose-minecraft
Run minecraft server using podman compose

## System configuration

Your system must support `podman`, `podman-compose`, and `apt-cacher-ng`.

On Ubuntu and similar, this should be sufficient:
```
sudo apt install podman-compose apt-cacher-ng
```

Setup the podman-compose systemd service:
```
sudo podman-compose systemd -a create-unit
```

Set

Create an ssh key to be able to ssh into service user accounts:
```
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_services
```

## Setup minecraft service user accout

Set up a suitable user to run the minecraft service and allow it to run services
```
sudo useradd -m -s /bin/bash service_minecraft
sudo loginctl enable-linger service_minecraft
sudo install -d -m 700 ~service_minecraft/.ssh
printf 'from=\"127.0.0.1,::1\" %s\n' "$(cat $HOME/.ssh/id_services.pub)" | sudo tee -a ~service_minecraft/.ssh/authorized_keys
sudo chmod 600 ~service_minecraft/.ssh/authorized_keys
sudo chown -R service_minecraft:service_minecraft ~service_minecraft/.ssh
# sudo restorecon -R /home/service_minecraft # <- may be needed on some systems
```

Now we can swap over to the service user account with ssh agent-forwarding (important if we want to auth to github):
```
ssh -A -i ~/.ssh/id_services service_minecraft@localhost
```

## Installation (run as `service_minecraft` user)

```
mkdir services
git clone 'git@github.com:rartino/podman-compose-minecraft.git' ~/services/minecraft
cd ~/services/minecraft
cp env.example .env
```
And edit the configuration to your liking with, e.g., `nano .env`.

Now download and build containers:
```
podman-compose pull
podman-compose build --no-cache
```

## Set up service (run as `service_minecraft` user)

You don't have to do this - if you prefer to run the server manually, see headline below.

Install the systemd service to autostart minecraft:
```
podman-compose --project-name minecraft systemd -a register
systemctl --user enable --now podman-compose@minecraft
```

Check the status when running as the `service_minecraft` user:
```
systemctl --user status podman-compose@minecraft
```

But, you can `exit` out of the `service_minecraft` user and go back to your regular user, where you can check the status as:
```
sudo systemctl --user -M service_minecraft@ status podman-compose@minecraft
```
And turn off/on the running service as:
```
sudo systemctl --user -M service_minecraft@ down podman-compose@minecraft
sudo systemctl --user -M service_minecraft@ up podman-compose@minecraft
```
And disable/re-enable the autostart at boot as:
```
systemctl --user disable --now podman-compose@minecraft
systemctl --user enable --now podman-compose@minecraft
```

## Manually running (don't do this if you installed the service!)

If you just want to start the minecraft server manually (you may want to do this inside, e.g., `screen` so you can leave it running):
```
podman-compose up
```
