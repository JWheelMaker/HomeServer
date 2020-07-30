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
    echo "Hello, $USER. Let's install your Traefik-Proxy."
    echo
}
install-traefik() {

    read -p "Have you already ran the script once? (yes/no)" answer
	if [ "$answer" == "no" ]
    then
		chmod 600 /opt/docker/traefik/data/acme.json;
		docker network create traefik_proxy;
		read -p "Please type in your Email-Address." email
	
		sed -i "s/mail@example.com/$email/" /opt/docker/traefik/data/traefik.yml;
	
		read -p "Please type in you Hostname." hostname
	
		sed -i "s/sub.domain.tld/$hostname/" /opt/docker/traefik/docker-compose.yml;
	
		read -p "Please type in a password for the Traefik Web-Interface." pw
		echo
		echo
		echo $(htpasswd -nb adminuser $pw) | sed -e s/\\$/\\$\\$/g;
		echo
		echo
		echo "Please copy the printed-out key and run the script again."
		exit
		
	else
		read -p "Please type in the copied Auth-Key." auth
		sed -i "s/auth.basicauth.users=/auth.basicauth.users=$auth/" /opt/docker/traefik/docker-compose.yml;
		leave
	fi	
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
install-traefik