#!/bin/bash

name="$1"
sshURL="$2"

nodePort=`./random_port.py`

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_github_rsa

mkdir /var/www/gitwrapper/$name
chmod 777 /var/www/gitwrapper/$name
cd /var/www/gitwrapper/$name


echo `pwd`
echo '============='
DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod

git clone $sshURL .
git checkout prod
git status
echo "=================="



# change https urls to ssh
perl -pi -e 's/https:\/\/github.com\//ssh:\/\/git\@github.com:/g' .gitmodules
git submodule sync
echo "=================="
./scripts/setup.sh
git stash
cp /var/www/local_settings.py project/settings/local_settings.py
echo "BRANCH = '$name'" >> project/settings/local_settings.py

# set up project from prod, load database


./manage.py createcachetable
./manage.py migrate
./manage.py loaddata /var/www/django.json

git checkout $name
# change https urls to ssh
perl -pi -e 's/https:\/\/github.com\//ssh:\/\/git\@github.com:/g' .gitmodules
git submodule sync
./scripts/setup.sh 
git stash
# python3 manage.py collectstatic --noinput
./manage.py migrate
chmod 777 db.sqlite3


# set up apache vhost
echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/$name.conf
echo "    ServerName $name.staging.bytedev.co" >> /etc/apache2/sites-enabled/$name.conf
echo "    Alias /static /var/www/gitwrapper/$name/staticfiles" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIDaemonProcess $name python-path=/var/www/gitwrapper/$name:/var/www/gitwrapper/$name/env:/var/www/gitwrapper/$name/env/lib/python3.5/site-packages" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIProcessGroup $name" >> /etc/apache2/sites-enabled/$name.conf
echo "    WSGIScriptAlias / /var/www/gitwrapper/$name/project/wsgi.py" >> /etc/apache2/sites-enabled/$name.conf
echo "</VirtualHost>" >> /etc/apache2/sites-enabled/$name.conf

/usr/sbin/service apache2 restart

exit 0
