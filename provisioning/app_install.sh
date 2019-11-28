#!/usr/bin/env bash
sudo yum -y update
mkdir ~/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash. ~/.nvm/nvm.shnvm install
#curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash. ~/.nvm/nvm.shnvm install
#. ~/.nvm/nvm.sh
nvm install node
sudo yum -y install git
mkdir /home/ec2-user/application
cd /home/ec2-user/application
git clone  https://github.com/jihanty/grx-sample-app.git/
cp /home/ec2-user/application/grx-sample-app/provisioning/app.sh /home/ec2-user
cd grx-sample-app/webapp
npm  install
npm  install -g  pm2@latest
pm2 start nodeexpressserver.js
