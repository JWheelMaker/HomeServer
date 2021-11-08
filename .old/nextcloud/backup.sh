#!/bin/bash
#
# Bash script for creating backups of Nextcloud.
#
# Version 2.1.0
#
# Usage:
#       - With backup directory specified in the script:  ./NextcloudBackup.sh
#       - With backup directory specified by parameter: ./NextcloudBackup.sh <BackupDirectory> (e.g. ./NextcloudBackup.sh /media/hdd/nextcloud_backup)
#
# The script is based on an installation of Nextcloud using nginx and MariaDB, see https://decatec.de/home-server/nextcloud-auf-ubuntu-server-18-04-lts-mit-nginx-mariadb-php-lets-encrypt-redis-und-fail2ban/
#

#
# IMPORTANT
# You have to customize this script (directories, users, etc.) for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#

# Variables
backupMainDir=$1

if [ -z "$backupMainDir" ]; then
        # TODO: The directory where you store the Nextcloud backups (when not specified by args)
    backupMainDir='/media/HDD1/nextcloud_backup'
else
        backupMainDir=$(echo $backupMainDir | sed 's:/*$::')
fi

currentDate=$(date +"%Y%m%d_%H%M%S")

# The actual directory of the current backup - this is a subdirectory of the main directory above with a timestamp
backupdir="${backupMainDir}/${currentDate}/"

# TODO: Use compression for Matrix Synapse installation/lib dir
# When this is the only script for backups, it's recommend to enable compression.
# If the output of this script is used in another (compressing) backup (e.g. borg backup),
# you should probably disable compression here and only enable compression of your main backup script.
useCompression=true

# TODO: The directory of your Nextcloud installation (this is a directory under your web root)
nextcloudFileDir='/opt/docker/nextcloud/app'

# TODO: The directory of your Nextcloud data directory (outside the Nextcloud file directory)
# If your data directory is located under Nextcloud's file directory (somewhere in the web root), the data directory should not be a separate part of the backup
nextcloudDataDir='/media/HDD1/ncdata'
nextcloudDBDir='/opt/docker/nextcloud/db'

# TODO: The directory of your Nextcloud's local external storage.
# Uncomment if you use local external storage.
#nextcloudLocalExternalDataDir='/var/nextcloud_external_data'

# TODO: The service name of the web server. Used to start/stop web server (e.g. 'systemctl start <webserverServiceName>')
webserverServiceName='apache2'

# TODO: Your web server user
webserverUser='www-data'

# TODO: The name of the database system (one of: mysql, mariadb, postgresql)
databaseSystem='mariadb'

# TODO: Your Nextcloud database name
nextcloudDatabase='nextcloud'

# TODO: Your Nextcloud database user
dbUser='nextcloud'

# TODO: The password of the Nextcloud database user
dbPassword='1234'

# TODO: The maximum number of backups to keep (when set to 0, all backups are kept)
maxNrOfBackups=2

# TODO: Ignore updater's backup directory in the data directory to save space
# Set to true to ignore the backup directory
ignoreUpdaterBackups=false

# File names for backup files
# If you prefer other file names, you'll also have to change the NextcloudRestore.sh script.
fileNameBackupFileDir='nextcloud-filedir.tar'
fileNameBackupDataDir='nextcloud-datadir.tar'
fileNameBackupDBDir='nextcloud-dbdir.tar'

if [ "$useCompression" = true ] ; then
        fileNameBackupFileDir='nextcloud-filedir.tar.gz'
        fileNameBackupDataDir='nextcloud-datadir.tar.gz'
		fileNameBackupDBDir='nextcloud-dbdir.tar.gz'

fi

# TODO: Uncomment if you use local external storage
#fileNameBackupExternalDataDir='nextcloud-external-datadir.tar'
#
#if [ "$useCompression" = true ] ; then
#       fileNameBackupExternalDataDir='nextcloud-external-datadir.tar.gz'
#fi

fileNameBackupDb='nextcloud-db.sql'

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

function DisableMaintenanceMode() {
        echo "Starting Docker-Container..."
        sudo docker-compose -f /opt/docker/nextcloud/docker-compose.yml up -d
        echo "Done"
        echo
}

# Capture CTRL+C
trap CtrlC INT

function CtrlC() {
        read -p "Backup cancelled. Leave Container shutted down? [y/n] " -n 1 -r
        echo

        if ! [[ $REPLY =~ ^[Yy]$ ]]
        then
                DisableMaintenanceMode
        else
                echo "Container still shutted down."
        fi

#       echo "Starting web server..."
#       systemctl start "${webserverServiceName}"
#       echo "Done"
#       echo

        exit 1
}

#
# Print information
#
echo "Backup directory: ${backupMainDir}"

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
        errorecho "ERROR: This script has to be run as root!"
        exit 1
fi

#
# Check if backup dir already exists
#
if [ ! -d "${backupdir}" ]
then
        mkdir -p "${backupdir}"
else
        errorecho "ERROR: The backup directory ${backupdir} already exists!"
        exit 1
fi

#
# Set maintenance mode
#
echo "Stopping Docker-Container..."
sudo docker-compose -f /opt/docker/nextcloud/docker-compose.yml down
echo "Done"
echo

#
# Stop web server
#
#echo "Stopping web server..."
#systemctl stop "${webserverServiceName}"
#echo "Done"
#echo

#
# Backup file directory
#
echo "Creating backup of Nextcloud file directory..."

if [ "$useCompression" = true ] ; then
        tar -cpzf "${backupdir}/${fileNameBackupFileDir}" -C "${nextcloudFileDir}" .
else
        tar -cpf "${backupdir}/${fileNameBackupFileDir}" -C "${nextcloudFileDir}" .
fi

echo "Done"
echo

echo "Backup Nextcloud database (MySQL/MariaDB)..."
tar -cpzf "${backupdir}/${fileNameBackupDBDir}" -C "${nextcloudDBDir}" .
cp /opt/docker/nextcloud/docker-compose.yml "${backupdir}"
echo "Done"

#
# Backup data directory
#
echo "Creating backup of Nextcloud data directory..."

if [ "$ignoreUpdaterBackups" = true ] ; then
        echo "Ignoring updater backup directory"

        if [ "$useCompression" = true ] ; then
                tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  --exclude="updater-*/backups/*" -C "${nextcloudDataDir}" .
        else
                tar -cpf "${backupdir}/${fileNameBackupDataDir}"  --exclude="updater-*/backups/*" -C "${nextcloudDataDir}" .
        fi
else
        if [ "$useCompression" = true ] ; then
        tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  -C "${nextcloudDataDir}" .
        else
                tar -cpf "${backupdir}/${fileNameBackupDataDir}"  -C "${nextcloudDataDir}" .
        fi
fi

echo "Done"
echo

# Backup local external storage.
# Uncomment if you use local external storage
#echo "Creating backup of Nextcloud local external storage directory..."

#if [ "$useCompression" = true ] ; then
#       tar -cpzf "${backupdir}/${fileNameBackupExternalDataDir}"  -C "${nextcloudLocalExternalDataDir}" .
#else
#       tar -cpf "${backupdir}/${fileNameBackupExternalDataDir}"  -C "${nextcloudLocalExternalDataDir}" .
#fi

#echo "Done"
#echo

#
# Backup DB
#

#
# Start web server
#
#echo "Starting web server..."
#systemctl start "${webserverServiceName}"
#echo "Done"
#echo

#
# Disable maintenance mode
#
DisableMaintenanceMode


#
# Delete old backups
#
if [ ${maxNrOfBackups} != 0 ]
then
        nrOfBackups=$(ls -l ${backupMainDir} | grep -c ^d)

        if [[ ${nrOfBackups} > ${maxNrOfBackups} ]]
        then
                echo "Removing old backups..."
                ls -t ${backupMainDir} | tail -$(( nrOfBackups - maxNrOfBackups )) | while read -r dirToRemove; do
                        echo "${dirToRemove}"
                        rm -r "${backupMainDir}/${dirToRemove:?}"
                        echo "Done"
                        echo
                done
        fi
fi

echo
echo "DONE!"
echo "Backup created: ${backupdir}"