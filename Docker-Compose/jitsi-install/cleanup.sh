#!/bin/bash
cleanup() {

    sleep 3s;
    rm -rf /opt/docker/jitsi-install;
	echo Cleanup was successfully executed!
    exit
}
cleanup