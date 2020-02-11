#!/bin/bash
############ VARS #####################
location=/backup/
date=`date -I"date"`
file=backupCitadel$date.tar.gz
target=$location$file
TAR_CMD="tar -cpf $target /usr/local/citadel/data /usr/local/citadel/network"
########################################

#main script
echo "Starting backup script."
#check if we are root
if [ "$EUID" -ne 0 ]
then
  echo "Please run as root."
  exit 126
fi

echo "MOUNTING /backup as /backup."
echo "Stop citadel."
docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=0

echo "Making backup of citadel docker volumes"
docker run --rm -v /backup/:/backup -v citadel-data:/usr/local/citadel/data -v citadel-alias:/usr/local/citadel/network debian:stretch $TAR_CMD

echo "Start citadel."

docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=1

echo  "Finished creating backup on $date"
exit 0
