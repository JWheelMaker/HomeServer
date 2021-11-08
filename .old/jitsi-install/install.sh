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
    echo "Hello, $USER. Let's install your Jitsi-Meet-Server."
    echo
}
install-jitsi() {
	sudo git clone https://github.com/jitsi/docker-jitsi-meet /opt/docker/jitsi-meet;
	check_exit_status
	
	sudo rm -r ~/.jitsi-meet-cfg/;
	
	mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody,jicofo,jvb,jigasi,jibri};
	check_exit_status
	
	sudo cp /opt/docker/jitsi-meet/env.example /opt/docker/jitsi-meet/.env;
	check_exit_status
	
	sudo /opt/docker/jitsi-meet/gen-passwords.sh;
	check_exit_status
	
	sed -i "s/#PUBLIC_URL/PUBLIC_URL/" /opt/docker/jitsi-meet/.env;
	sed -i "s/meet.example.com/$hostname/" /opt/docker/jitsi-meet/.env;
		
	leave
}
leave() {

    echo
    echo "--------------------"
    echo "- Setup Complete ! -"
    echo "--------------------"
    echo
	cd /opt/docker/;
	bash /opt/docker/jitsi-meet/cleanup.sh;
    exit
}

greeting
install-jitsi