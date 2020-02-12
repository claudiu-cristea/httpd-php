#!bin/bash
set -e
set -x

# Fix www-data uid/gid :
#usermod -u ${USER_ID} www-data
#groupmod -g ${GROUP_ID} www-data

# Force usage of local repos
sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' -e 's/http:\/\/security/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list

apt-get update
apt-get dist-upgrade -y
apt-get install -y software-properties-common
add-apt-repository -y ppa:ondrej/php

if [ echo $php_version | awk '{if ($1 > 7.1) print 1; else print 0}' ] 
then
	php_modules=$(echo ${php_modules} | sed 's/mcrypt//')
fi

modules=$(printf "php${php_version}-%s " ${php_modules})

apt-get install -y apache2 php${php_version}-fpm ${modules} msmtp

apt-get autoremove software-properties-common -y --purge
apt-get clean
rm -rf /var/lib/apt/lists/*

ln -s /bin/true /usr/sbin/sendmail

mkdir /etc/supervisor/
