#! /bin/bash
mkdir ~/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
sudo yum -y install git
mkdir /home/ec2-user/application
cd /home/ec2-user/application
git clone  https://github.com/jihanty/grx-sample-app.git/
cd grx-sample-app/webapp
npm  install
npm  install -g  pm2@latest
pm2 start nodeexpressserver.js
