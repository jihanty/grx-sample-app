#!/usr/bin/env bash
sudo yum -y update
mkdir ~/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
sudo yum -y install git
mkdir /opt/application
chown ec2-user.ec2-user /opt/application
cd /opt/application
git clone  https://github.com/jihanty/grx-sample-app.git/
cd grx-sample-app/webapp
npm  install
npm  install -g  pm2@latest
pm2 start nodeexpressserver.js