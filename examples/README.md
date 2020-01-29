docker-citadel
================================
See docker-compose.yml for an example docker compose file. This provides you with citadel, clamav and spamassassin.
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

Citadel logs to /var/log/auth.log. You can monitor auth.log for failed login attempt to SMPT.
Below is an example for monitoring and banning for failed login attempts for SMTP.

It DOES NOT check for failed logon attempts on webcit!

Example jail.local excerpt
---------------------
    [citadel]
    enabled  = true
    filter   = citadel
    logpath  = /var/log/citadel/syslog
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


