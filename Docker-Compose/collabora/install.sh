#!/bin/bash
greeting() {

    echo
    echo "Hello, $USER. Let's install Collabora."
    echo
}
adjust() {
	read -p "Please now type in your hostname." hostname
	sed -i "s/sub.domain.tld/$hostname/" /opt/docker/collabora/docker-compose.yml;
	
	read -p "Please now type in your password for the admin-panel." password
	sed -i "s/password=/password=$password/" /opt/docker/collabora/docker-compose.yml;
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
adjust
leave