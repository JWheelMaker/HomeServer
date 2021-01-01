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
		read -p "Please type in your hostname." hostname
		read -p "Please type in a new MYSQL_ROOT_PASSWORD." mysql_rpw
		read -p "Please type in a new MYSQL_PASSWORD." mysql_pw
		read -p "Please type in a new Redis-Password." redispw
		sed -i "s/MYSQL_ROOT_PASSWORD=/MYSQL_ROOT_PASSWORD=$mysql_rpw/" /opt/docker/nextcloud/docker-compose.yml;
		sed -i "s/MYSQL_PASSWORD=/MYSQL_PASSWORD=$mysql_pw/" /opt/docker/nextcloud/docker-compose.yml;
		sed -i "s/sub.domain.tld/$hostname/" /opt/docker/nextcloud/docker-compose.yml;
		sed -i "s/redispw/$redispw/" /opt/docker/nextcloud/docker-compose.yml;
		docker inspect traefik | grep IPAddress;
		read -p "Please type in the IPAddress." ipaddress
		sed -i "s/123.45.6.7/$ipaddress/" app/config/config.php;
		sed -i "s/sub.domain.tld/$hostname/" app/config/config.php;
		chown -R www-data:www-data app/;
		chown -R www-data:www-data data/;
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