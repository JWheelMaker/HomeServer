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

echo
echo "--------------------"
echo "- Setup Complete ! -"
echo "--------------------"
echo
exit
