#!/bin/bash

name="$1"
sshURL="$2"

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_github_rsa
mkdir /var/www/gitwrapper/$name
cd /var/www/gitwrapper/$name
echo `pwd`

DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod

git clone $sshURL .
git checkout $name
virtualenv env
source env/bin/activate

pip install -r requirements.txt 
cp /var/www/local_settings.py project/settings/local_settings.py
echo "BRANCH = '$name'" >> project/settings/local_settings.py

python3 manage.py loaddata "/var/www/django.dump"
python3 manage.py collectstatic --noinput
python3 manage.py migrate
chmod 777 .
chmod 777 db.sqlite3

echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/$name.conf
echo "    ServerName $name.staging.bytedev.co" >> /etc/apache2/sites-enabled/$name.conf
echo "    Alias /static /var/www/gitwrapper/$name/staticfiles" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIDaemonProcess $name python-path=/var/www/gitwrapper/$name:/var/www/gitwrapper/$name/env:/var/www/gitwrapper/$name/env/lib/python3.5/site-packages" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIProcessGroup $name" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIScriptAlias / /var/www/gitwrapper/$name/project/wsgi.py" >> /etc/apache2/sites-enabled/$name.conf
echo "</VirtualHost>" >> /etc/apache2/sites-enabled/$name.conf


service apache2 restart

# copy and make data base
