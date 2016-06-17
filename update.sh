#!/bin/bash
name="$1"
sshURL="$2"

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_github_rsa
DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod
cd /var/www/gitwrapper/$name

source env/bin/activate

git stash
git pull --force origin $name
pip install -r requirements.txt 

python3 manage.py collectstatic --noinput
python3 manage.py migrate

chmod 777 .
chmod 777 db.sqlite3
service apache2 reload

exit 0