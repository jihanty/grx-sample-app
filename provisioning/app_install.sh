#!/bin/bash
cat > /tmp/subscript.sh << EOF
# START
echo "Setting up NodeJS Environment"
curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

echo 'export NVM_DIR="/home/ec2-user/.nvm"' >> /home/ec2-user/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/ec2-user/.bashrc

# Dot source the files to ensure that variables are available within the current shell
. /home/ec2-user/.nvm/nvm.sh
. /home/ec2-user/.bashrc

# Install NVM, NPM, Node.JS & Grunt
nvm alias default v12.7.0
nvm install v12.7.0
nvm use v12.7.0
sudo yum -y install git
cd /home/ec2-user
git clone  https://github.com/jihanty/grx-sample-app.git/
cd grx-sample-app/webapp
npm  install
npm  install -g  pm2@latest
pm2 start nodeexpressserver.js
EOF

chown ec2-user:ec2-user /tmp/subscript.sh && chmod a+x /tmp/subscript.sh
sleep 1; su - ec2-user -c "/tmp/subscript.sh"