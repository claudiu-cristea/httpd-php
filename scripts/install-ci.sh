#!bin/bash
set -e
set -x
apt-get update

# Install ci packages :
apt-get install -y ${ci_packages}

adduser www-data root

# Install NodeJS:
curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
curl -sL https://deb.nodesource.com/setup_10.x | bash -

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

apt-get update
apt-get install -y nodejs yarn build-essential

cd /opt

yarn add --cache-folder /tmp wetty.js

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -Rf /root/.composer/cache
