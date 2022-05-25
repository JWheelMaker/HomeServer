#!/bin/bash
 echo
 echo "Hello, $USER. Let's get this system to the HomeServer Main-Setup."
 echo


#up-script
chmod a+x ./scripts/up-command.sh;
mv ./scripts/up-command.sh /bin/up;
export PATH=/bin:$PATH;

#install docker engine
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
	
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo apt install ddclient

#install docker compose
sudo apt-get instll docker-compose-plugin
docker compose version

#moving scripts to root dir
cp -R ./scripts /
chmod +x /scripts/*

#fixing permissions for nextcloud app folder
mkdir /opt/docker;
mkdir -p /opt/docker/nextcloud/app
chown -R www-data:www-data /opt/docker/nextcloud/app

#setting up portainer
cp -R ./manual/portainer /opt/docker
cd /opt/docker/portainer
docker compose pull
docker compose up -d

echo Visit http://IP-ADDRESS:9000 to configure portainer.


echo
echo "--------------------"
echo "- Setup Complete ! -"
echo "--------------------"
echo
exit

up
