#!/bin/bash
name="$1"
sshURL="$2"

rm -rf /var/www/gitwrapper/$name
rm /etc/apache2/sites-enabled/$name.conf

/usr/sbin/service apache2 restart

exit 0
