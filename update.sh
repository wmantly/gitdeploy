#!/bin/bash
name="$1"
sshURL="$2"
workingPath=/var/www/gitwrapper/$name

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_github_rsa
cd $workingPath


DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod
source env/bin/activate

git stash
git pull --force origin $name

./scripts/setup.sh
source env/bin/activate

python3 manage.py collectstatic --noinput
python3 manage.py migrate

chmod 777 .
chmod 777 db.sqlite3

echo "starting node app"
NODE_ENV='staging'
export NODE_ENV='staging'
nodePort=cat env/nodePort
export NODEPORT=$nodePort
forever stop $workingPath/node_rtc/app.js
forever start $workingPath/node_rtc/app.js

/usr/sbin/service apache2 restart

exit 0
