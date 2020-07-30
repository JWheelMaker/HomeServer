#!/bin/bash
greeting() {

    echo
    echo "Hello, $USER. Let's install your Bitwarden-Server."
    echo
}
adjust() {
	read -p "Please now type in your hostname." hostname
	sed -i "s/sub.domain.tld/$hostname/" /opt/docker/bitwarden/docker-compose.yml;
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