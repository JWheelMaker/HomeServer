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
update-script() {

    sudo chmod a+x update.sh;
    check_exit_status

    sudo mv update.sh /bin/up;
    check_exit_status

    export PATH=/bin:$PATH;
    check_exit_status
}
main-software() {

    sudo apt install -y docker.io curl git software-properties-common apache2-utils;
        check_exit_status

        sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        check_exit_status

        sudo chmod +x /usr/local/bin/docker-compose
        check_exit_status

        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        check_exit_status

        docker-compose --version;
        mkdir /opt/docker;
}
leave() {

    echo
    echo "--------------------"
    echo "- Setup Complete ! -"
    echo "--------------------"
    echo
        echo
        echo "Please run    export PATH=~/bin:$PATH    to complete the installation."
    exit
}


greeting
update-script
up
main-software
leave
