#!/bin/bash
set -e
cd /home/isucon/webapp
git pull
cd perl
carton install
cd ../
# rsync -a --delete --exclude=**/perl/pages/* /home/isucon/webapp/ isucon@app1:/home/isucon/webapp/ &
# rsync -a --delete --exclude=**/perl/pages/* /home/isucon/webapp/ isucon@app2:/home/isucon/webapp/ &
# wait
sudo /usr/sbin/supervisorctl reload &
# ssh isucon@app1 sudo /usr/sbin/supervisorctl reload &
# ssh isucon@app2 sudo /usr/sbin/supervisorctl reload &
# wait
echo "done!!!"
