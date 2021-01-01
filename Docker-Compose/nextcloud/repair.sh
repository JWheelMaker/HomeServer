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
    echo "Hello, $USER. Let's Repair your Nextcloud."
    echo
}
repair() {

    read -p "Is your Nextcloud-Instance running AND have you already created an admin user? (yes/no)" answer
	if [ "$answer" == "yes" ]
    then
		docker-compose exec --user www-data nextcloud-app php occ db:add-missing-indices
		docker-compose exec --user www-data nextcloud-app php occ maintenance:repair
		docker-compose exec --user www-data nextcloud-app php occ db:add-missing-columns
		docker-compose exec --user www-data nextcloud-app php occ db:add-missing-primary-keys
		leave
		
	else
		echo
		echo
		echo "Please start you Nextcloud-Instance!"
		echo
		exit
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
repair