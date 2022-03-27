#!/bin/sh
echo
echo "Hello, $USER. Let's upgrade your Docker-Containers."
echo
cd /opt/docker/portainer/data/compose
for verzeichnis in *
do
        if [ -d "${verzeichnis}" ]
        then
                echo
                echo
                echo "${verzeichnis}:"
            echo
        cd "${verzeichnis}"
            docker compose pull
            read -p "Should this instance be restarted?(y/n)" answer
                if [ "$answer" = "y" ]
                then
                        docker compose down
                        docker compose up -d
                fi
        cd ..
        fi
done

docker exec --user www-data nextcloud-app php occ app:update --all

echo
echo "--------------------"
echo "- Upgrade Complete!-"
echo "--------------------"
echo
exit