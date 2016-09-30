#!/bin/bash
name="$1"
sshURL="$2"

# set up git to auth
eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_github_rsa

DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod

cd /var/www/gitwrapper/$name
git stash
git pull --force origin $name

./scripts/setup.sh

python3 manage.py collectstatic --noinput
python3 manage.py migrate

chmod 777 .
chmod 777 db.sqlite3

/usr/sbin/service apache2 restart

exit 0
