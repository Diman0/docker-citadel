#!/bin/bash
echo "MOUNTING /backup as /backup."
echo "Place backups in this folder"
echo "Stopping citadel."
docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=0
echo "Starting backup container"
echo "Example extract command: tar -x -f /backup/backupCitadel.tar.gz -v "
docker run -it --rm -v /backup/:/backup -v citadel-data:/usr/local/citadel/data debian:stretch /bin/bash
echo "Starting citadel"
docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=1
echo  "Done "; date
