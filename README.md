docker-citadel
======================
Home of citadel: http://citadel.org

Citadel as a Docker Image. Citadel is build using easyinstall method. Setup has not been run to configure the installation.

Supervisord (http://supervisord.org) is used to monitor the citadel/webcit programs. It stops the container if citadel/webcit fails or exits.

Usage 
--------------
    docker run  -d --name citadel -p "25:25" -p "80:80" -p "143:143"  -p "465:465" -p "587:587" -p "993:993"
For data persistence I recommended using volumes for the the data folder (database) and mail.aliases mapping file.

    docker run  -d --name citadel -p "25:25" -p "80:80" -p "143:143"  -p "465:465" -p "587:587" -p "993:993" --mount 'type=volume,src=citadel-data,dst=/usr/local/citadel/data' --mount 'type=volume,src=citadel-alias,dst=/usr/local/citadel/network/mail.aliases'

With a network in case you are linking the container with a clamav and spamassassin container: 

    docker run  -d --name citadel -p "25:25" -p "80:80" -p "143:143"  -p "465:465" -p "587:587" -p "993:993" --mount 'type=volume,src=citadel-data,dst=/usr/local/citadel/data' --mount 'type=volume,src=citadel-alias,dst=/usr/local/citadel/network/mail.aliases'--network citadel-network

Next step is configuring citadel for first time usage.

Configuration
-----------------
After starting the container for the first time, you must run setup once to configure citadel.
    
    docker exec -it citadel bash  (where citadel is the name of the container)

    /usr/local/citadel/setup

    supervisorctl restart all

    Previous command will stop the container. Now start the container again. docker container start --name citadel

NOTE: If you create a new container and re-use the data volumes, then you do not have to run setup. As all configuration resides in the database, the container will immediately be up and running with all your configuration and data retained. The only exceptions are the mail.aliases file and files related to BBS functionality. See data files section in http://citadel.org/doku.php?id=documentation:file_layout#files.and.where.easy.install.and.lhfs.rpm.deb.installs.put.them for more info. If you use this BBS functionality you could create volumes for these folders as well.

Tags
-----------------
* latest = should be latest release tag, but can be experimental. Please do not use latest.
* release-v928
* release-v927
* release-v925


