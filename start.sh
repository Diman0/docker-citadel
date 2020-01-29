#!/bin/bash
#start rsyslog
/etc/init.d/rsyslog start
#start supervisor
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
