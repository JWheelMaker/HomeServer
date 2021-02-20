#!/bin/bash
#
# Bash script for restoring backups of Nextcloud.
#
# Version 2.1.0
#
# Usage:
#   - With backup directory specified in the script: ./NextcloudRestore.sh <BackupName> (e.g. ./NextcloudRestore.sh 20170910_132703)
#   - With backup directory specified by parameter: ./NextcloudRestore.sh <BackupName> <BackupDirectory> (e.g. ./NextcloudRestore.sh 20170910_132703 /media/hdd/nextcloud_backup)
#
# The script is based on an installation of Nextcloud using nginx and MariaDB, see https://decatec.de/home-server/nextcloud-auf-ubuntu-server-18-04-lts-mit-nginx-mariadb-php-lets-encrypt-redis-und-fail2ban/
#

#
# IMPORTANT
# You have to customize this script (directories, users, etc.) for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#

# Variables
restore=$1
backupMainDir=$2

if [ -z "$backupMainDir" ]; then
	# TODO: The directory where you store the Nextcloud backups (when not specified by args)
    backupMainDir='/media/HDD1/nextcloud_backup'
fi

echo "Backup directory: $backupMainDir"

# TODO: Set this to true, if the backup was created with compression enabled, otherwiese false.
useCompression=true

currentRestoreDir="${backupMainDir}/${restore}"

# TODO: The directory of your Nextcloud installation (this is a directory under your web root)
nextcloudFileDir='/opt/docker/nextcloud/app'

# TODO: The directory of your Nextcloud data directory (outside the Nextcloud file directory)
# If your data directory is located under Nextcloud's file directory (somewhere in the web root), the data directory should not be restored separately
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

# File names for backup files
# If you prefer other file names, you'll also have to change the NextcloudBackup.sh script.
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
#    fileNameBackupExternalDataDir='nextcloud-external-datadir.tar.gz'
#fi

fileNameBackupDb='nextcloud-db.sql'

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Check if parameter(s) given
#
if [ $# != "1" ] && [ $# != "2" ]
then
    errorecho "ERROR: No backup name to restore given, or wrong number of parameters!"
    errorecho "Usage: NextcloudRestore.sh 'BackupDate' ['BackupDirectory']"
    exit 1
fi

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
    errorecho "ERROR: This script has to be run as root!"
    exit 1
fi

#
# Check if backup dir exists
#
if [ ! -d "${currentRestoreDir}" ]
then
	errorecho "ERROR: Backup ${restore} not found!"
    exit 1
fi


#
# Stop web server
#
echo "Stopping Docker Container..."
sudo docker-compose -f /opt/docker/nextcloud/docker-compose.yml down
echo "Done"
echo

#
# Delete old Nextcloud directories
#

# File directory
echo "Deleting old Nextcloud file directory..."
rm -r "${nextcloudFileDir}"
mkdir -p "${nextcloudFileDir}"
echo "Done"
echo

# Data directory
echo "Deleting old Nextcloud data directory..."
rm -r "${nextcloudDataDir}"
mkdir -p "${nextcloudDataDir}"
echo "Done"
echo

# Data directory
echo "Deleting old Nextcloud database directory..."
rm -r "${nextcloudDBDir}"
mkdir -p "${nextcloudDBDir}"
echo "Done"
echo

# Local external storage
# TODO: Uncomment if you use local external storage
#echo "Deleting old Nextcloud local external storage directory..."
#rm -r "${nextcloudLocalExternalDataDir}"
#mkdir -p "${nextcloudLocalExternalDataDir}"
#echo "Done"
#echo

#
# Restore file and data directory
#

# File directory
echo "Restoring Nextcloud file and database directory..."

if [ "$useCompression" = true ] ; then
    tar -xmpzf "${currentRestoreDir}/${fileNameBackupFileDir}" -C "${nextcloudFileDir}"
    tar -xmpzf "${currentRestoreDir}/${fileNameBackupDBDir}" -C "${nextcloudDBDir}"
else
    tar -xmpf "${currentRestoreDir}/${fileNameBackupFileDir}" -C "${nextcloudFileDir}"
fi

echo "Done"
echo

# Data directory
echo "Restoring Nextcloud data directory..."

if [ "$useCompression" = true ] ; then
    tar -xmpzf "${currentRestoreDir}/${fileNameBackupDataDir}" -C "${nextcloudDataDir}"
else
    tar -xmpf "${currentRestoreDir}/${fileNameBackupDataDir}" -C "${nextcloudDataDir}"
fi

echo "Done"
echo

# Local external storage
# TODO: Uncomment if you use local external storage
#echo "Restoring Nextcloud data directory..."
#
#if [ "$useCompression" = true ] ; then
#    tar -xmpzf "${currentRestoreDir}/${fileNameBackupExternalDataDir}" -C "${nextcloudLocalExternalDataDir}"
#else
#    tar -xmpf "${currentRestoreDir}/${fileNameBackupExternalDataDir}" -C "${nextcloudLocalExternalDataDir}"
#fi
#
#echo "Done"
#echo

#
# Start web server
#
echo "Starting Docker Container..."
sudo docker-compose -f /opt/docker/nextcloud/docker-compose.yml up -d
echo "Done"
echo

#
# Set directory permissions
#
echo "Setting directory permissions..."
chown -R "${webserverUser}":"${webserverUser}" "${nextcloudFileDir}"
chown -R "${webserverUser}":"${webserverUser}" "${nextcloudDataDir}"
# TODO: Uncomment if you use local external storage
#chown -R "${webserverUser}":"${webserverUser}" "${nextcloudLocalExternalDataDir}"
echo "Done"
echo

#
# Update the system data-fingerprint (see https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html#maintenance-commands-label)
#
echo "Updating the system data-fingerprint..."
docker exec --user "${webserverUser}" nextcloud-app php occ maintenance:data-fingerprint
echo "Done"
echo


echo
echo "DONE!"
echo "Backup ${restore} successfully restored."