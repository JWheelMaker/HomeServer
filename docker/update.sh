#!/bin/sh
echo
echo "Hello, $USER. Let's update your Docker-Containers."
echo
for verzeichnis in *
do
	if [ -d "${verzeichnis}" ]
	then
		echo
		echo
		echo "${verzeichnis}:"
	    echo
        cd "${verzeichnis}"
	    docker-compose pull
	    read -p "Should this instance be restarted?(y/n)" answer
		if [ "$answer" == "y" ]
		then
			docker-compose down
			docker-compose up -d
		fi
        cd ..
	fi
done

read -p "Should the Nextcloud cron-job be done now?(y/n)" answer
    if [ "$answer" == "y" ]
    then
            cd nextcloud/
            docker-compose exec --user www-data nextcloud-app php -f cron.php
    fi

cd nextcloud
docker-compose exec --user www-data nextcloud-app php occ app:update --all

echo
echo "--------------------"
echo "- Setup Complete ! -"
echo "--------------------"
echo
exit
