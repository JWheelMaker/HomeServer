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

    sudo mkdir ~/bin;
    check_exit_status

    sudo mv update.sh ~/bin/up;
    check_exit_status

    sudo export PATH=~/bin:$PATH;
    check_exit_status

    sudo source ~/.bashrc;
    check_exit_status
}
main-software() {

    sudo apt install -y docker curl git software-properties-common;
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
update-script
sudo up
main-software
leave
