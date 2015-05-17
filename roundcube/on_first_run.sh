#!/bin/sh
DES_KEY=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-24};echo;)
sed -e "s/@DES_KEY@/$DES_KEY/g" /root/config.inc.php > /rc/config.inc.php
mysql -u$DB_USER -p$DB_PASSWD $DB_NAME</root/roundcubemail.sql
chown -R www-data:www-data /rc
