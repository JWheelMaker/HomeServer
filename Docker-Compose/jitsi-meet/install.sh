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
    echo "Hello, $USER. Let's get this system to the HomeServer Main-Setup."
    echo
}
install-jitsi() {
    sudo git clone https://github.com/jitsi/docker-jitsi-meet /opt/docker/jitsi-meet;
	check_exit_status
	
	sudo rm -r ~/.jitsi-meet-cfg/
	
	sudo mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody,jicofo,jvb,jigasi,jibri};
	check_exit_status
	
	sudo cp env.example .env;
	check_exit_status
	
	sudo ./gen-passwords.sh;
	check_exit_status
	
	sudo rm docker-compose.yml;
	check_exit_status
	
	sudo mv newdocker-compose.yml docker-compose.yml;
	check_exit_status
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
install-jitsi
leave