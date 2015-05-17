#!/bin/sh
exec 2>&1
php5enmod imap
if [ ! -e /root/configured ];then
  mysql -u$DB_USER -p$DB_PASSWD --host=mysql $DB_NAME < /root/database.sql
  touch /root/configured
  unset MYSQL_ROOT_PASSWORD
fi
apachectl -DFOREGROUND
