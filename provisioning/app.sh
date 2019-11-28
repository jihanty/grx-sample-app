#!/usr/bin/env bash
sudo yum -y update
sudo mkdir /home/ec2-user/.nvm
sudo chown ec2-user.ec2-user /home/ec2-user/.nvm
cd /home/ec2-user
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. /home/ec2-user/.nvm/nvm.sh
nvm install node
sudo yum -y install git
mkdir /home/ec2-user/application
cd /home/ec2-user/application
git clone  https://github.com/jihanty/grx-sample-app.git/
cd grx-sample-app/webapp
npm  install
npm  install -g  pm2@latest
pm2 start nodeexpressserver.js
