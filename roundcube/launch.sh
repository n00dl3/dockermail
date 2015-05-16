#!/bin/bash
exec 2>&1
if [ ! -e /root/configured ];then
  DES_KEY=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
  sed -e "s/@DES_KEY@/$DES_KEY/g" /root/config.inc.php > /rc/config.inc.php
  mysql -u$DB_USER -p$DB_PASSWD $DB_NAME</root/roundcubemail.sql
fi
chown -R www-data:www-data /rc
apachectl -DFOREGROUND
