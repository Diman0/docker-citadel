docker-citadel
================================
See docker-compose.yml for an example docker compose file. This provides you with citadel, clamav and spamassassin.

To start citadel stack use docker-compose
    docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d
    
Docker-compose uses a so called project name that will be prepended to all container names. By default this is the folder name. To avoid conflicts, you can specify the project name via -p. This will create the containers mail_citadel_1, mail_clamav_1 and mail_spamassassin_1. You must specify "-d" to make sure the containers are started in the background. Default behaviour of docker-compose is to start in the foreground.

I use letsencrypt for certificates and make them available to the container via bind mount.
I make the /var/log folder of the container available to the host, because I have fail2ban running on the host
that monitors this file. 

      - type: bind
        source: /etc/letsencrypt/live/<REDACTED>/privkey.pem
        target: /usr/local/citadel/keys/citadel.key
        read_only: true
      - type: bind
        source: /etc/letsencrypt/live/<REDACTED>/fullchain.pem
        target: /usr/local/citadel/keys/citadel.cer
        read_only: true
      - type: bind
        source: /var/log/citadel
        target: /var/log

If you create a bind mount as above for /var/log, then you must create the (local) folders
* /var/log/citadel/supervisor_log
* /var/log/citadel/

The supervisor_log folder is used by supervisor for logging std out and std err of citadel and webcit. 
 
Citadel logs to /var/log/auth.log. You can monitor auth.log for failed login attempts to SMPT.
Below is an example for monitoring and banning for failed login attempts for SMTP.

It DOES NOT check for failed logon attempts on webcit!

Example jail.local excerpt
---------------------
    [citadel]
    enabled  = true
    filter   = citadel
    logpath  = /var/log/citadel/auth.log
    maxretry = 5
    bantime = 24h
    findtime = 24h

Example filter.d /etc/fail2ban/filter.d/citadel.conf
----------------------
    [INCLUDES]
    before = common.conf

    [Definition]
    failregex = user_ops: bad password specified for .* Service .* Port .* Remote .* \/.<HOST>>

    ignoreregex = 

    journalmatch = SYSLOG_IDENTIFIER=citserver

Creating a backup
----------------------
Creating a backup is a matter of temporarily stopping the citadel container and creating a tar archive. See backupContainer.sh for an example script. E.g.
* docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=0

This command informs docker-compose to reduce the amount of citadel containers to 0.
Now mount the citadel data volume and create a backup using tar.

* docker run --rm -v /backup/:/backup -v citadel-data:/usr/local/citadel/data -v citadel-alias:/usr/local/citadel/network debian:stretch "tar -cpf /backup/citadelBackup.tar.gz /usr/local/citadel/data /usr/local/citadel/network

Start the citadel container again. 

* docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=1

Note the "-d" parameter for docker-compose. You must specify "-d" to make sure the containers are started in the background. Default behaviour of docker-compose is to start in the foreground.

Restoring a backup
---------------------
Restoring your backup is a matter of extracting the tar backup archive to your data volume. See restoreBackupContainer.sh for an example script.

Stop citadel.

* docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=0

Start interactive docker container for extracting the tar archive. 
* docker run -it --rm -v /backup/:/backup -v citadel-data:/usr/local/citadel/data -v citadel-alias:/usr/local/citadel/network debian:stretch /bin/bash

In the container extract the tar archive

* tar -x -f /backup/backupCitadel.tar.gz -v 

Start citadel again

* docker-compose -p mail -f /scripts/docker/docker-compose.yml up -d --no-recreate --scale citadel=1
