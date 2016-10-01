#!/bin/bash

name="$1"
sshURL="$2"

echo "starting $sshURL on $name"

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_github_rsa
mkdir /var/www/gitwrapper/$name
cd /var/www/gitwrapper/$name
chmod 777 .
echo `pwd`

DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod

git clone $sshURL .

./scripts/setup.sh

source env/bin/activate

cp /var/www/local_settings.py project/settings/local_settings.py
echo "BRANCH = '$name'" >> project/settings/local_settings.py

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

echo "creating apache VirtualHost file"

echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/$name.conf
echo "    ServerName $name.staging.bytedev.co" >> /etc/apache2/sites-enabled/$name.conf
echo "    Alias /static /var/www/gitwrapper/$name/staticfiles" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIDaemonProcess $name python-path=/var/www/gitwrapper/$name:/var/www/gitwrapper/$name/env:/var/www/gitwrapper/$name/env/lib/python3.5/site-packages" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIProcessGroup $name" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIScriptAlias / /var/www/gitwrapper/$name/project/wsgi.py" >> /etc/apache2/sites-enabled/$name.conf
echo "</VirtualHost>" >> /etc/apache2/sites-enabled/$name.conf

/usr/sbin/service apache2 restart

exit 0
