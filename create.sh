#!/bin/bash

name="$1"
sshURL="$2"

echo "starting $sshURL on $name"

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_github_rsa
mkdir $workingPath
cd $workingPath
chmod 777 .
echo `pwd`

workingPath = /var/www/gitwrapper/$name
nodePort = `./random_port.py`
DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod

NODE_ENV = 'staging'
export NODE_ENV = 'staging'

git clone $sshURL .

./scripts/setup.sh

source env/bin/activate

cp /var/www/local_settings.py project/settings/local_settings.py
echo "BRANCH = '$name'" >> project/settings/local_settings.py
echo "NODEPORT = '$name'" >> project/settings/local_settings.py

echo "checking out to prod for set up"
git checkout prod

python3 manage.py createcachetable
python3 manage.py migrate
python3 manage.py loaddata /var/www/django.json

echo "checking out to $name for set up"
git checkout $name

./scripts/setup.sh 

python3 manage.py collectstatic --noinput
python3 manage.py migrate
chmod 777 db.sqlite3

echo "starting node add"
forever stop $workingPath/node_rtc/app.js
forever start $workingPath/node_rtc/app.js

echo "creating apache VirtualHost file"

echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/$name.conf
echo "    ServerName $name.staging.bytedev.co" >> /etc/apache2/sites-enabled/$name.conf
echo "    Alias /static $workingPath/staticfiles" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIDaemonProcess $name python-path=$workingPath:$workingPath/env:$workingPath/env/lib/python3.5/site-packages" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIProcessGroup $name" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIScriptAlias / $workingPath/project/wsgi.py" >> /etc/apache2/sites-enabled/$name.conf
echo "    <Location '/socket.io'>" >> /etc/apache2/sites-enabled/$name.conf
echo "        ProxyPass http://localhost:$nodePort/V1" >> /etc/apache2/sites-enabled/$name.conf
echo "        ProxyPassReverse http://localhost:$nodePort/V1" >> /etc/apache2/sites-enabled/$name.conf
echo "    </Location>" >> /etc/apache2/sites-enabled/$name.conf
echo "</VirtualHost>" >> /etc/apache2/sites-enabled/$name.conf

/usr/sbin/service apache2 restart

exit 0
