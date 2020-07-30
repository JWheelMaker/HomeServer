#!/bin/bash

check_exit_status() {

    if [ $? -eq 0 ]
    then
        echo
        echo "Success"
        echo
    else
        echo
        echo "[ERROR] Process Failed!"
        echo
        read -p "The last command exited with an error. Exit script? (yes/no) " answer

        if [ "$answer" == "yes" ]
        then
            exit 1
        fi
    fi
}
greeting() {

    echo
    echo "Hello, $USER. Let's install your Nextcloud-Server."
    echo
}
install-nextcloud() {
	read -p "Have you already ran this script once? (yes/no)" answer
	if [ "$answer" == "no" ]
	then
		read -p "Please type in your hostname." hostname
		read -p "Please type in a new MYSQL_ROOT_PASSWORD." mysql_rpw
		read -p "Please type in a new MYSQL_PASSWORD." mysql_pw
		sed -i "s/MYSQL_ROOT_PASSWORD=/MYSQL_ROOT_PASSWORD=$mysql_rpw/" /opt/docker/nextcloud/docker-compose.yml;
		sed -i "s/MYSQL_PASSWORD=/MYSQL_PASSWORD=$mysql_pw/" /opt/docker/nextcloud/docker-compose.yml;
		sed -i "s/sub.domain.tld/$hostname/" /opt/docker/nextcloud/docker-compose.yml;
	fi
	read -p "Have you already started your NC-Server once and is it running? (yes/no)" answer
	if [ "$answer" == "no" ]
    then
        exit 1
    fi
    docker inspect traefik | grep IPAddress;
	read -p "Please type in the IPAddress." ipaddress
	docker-compose exec --user www-data nextcloud-app php occ config:system:set trusted_proxies 0 --value=$ipaddress;
	
	sed -i "s/overwrite.cli.url' => 'http:/overwrite.cli.url' => 'https:/" /opt/docker/nextcloud/app/config/config.php;
	docker-compose exec --user www-data nextcloud-app php occ config:system:set overwriteprotocol --value=https;
	docker-compose exec --user www-data nextcloud-app php occ config:system:set overwritehost --value=$hostname;
}
leave() {

    echo
    echo "--------------------"
    echo "- Setup Complete ! -"
    echo "--------------------"
    echo
    exit
}

greeting
install-nextcloud
leave