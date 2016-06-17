#!/bin/bash
name="$1"
sshURL="$2"

rm -rf /var/www/gitwrapper/$name
rm /etc/apache2/sites-enabled/$name.conf

service apache2 reload

exit 0
