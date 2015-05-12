#!/bin/sh
exec 2>&1
php5enmod imap
if [ ! -e /root/configured ];then
  if [ -z $DB_NAME ] || [ -z $DB_USER ] || [ -z $DB_PASSWD ];then
    echo "you should set every environment variables to run this container"
    exit 2
  fi
  mysql -u$DB_USER -p$DB_PASSWD --host=mysql $DB_NAME < /root/database.sql
  touch /root/configured
  unset MYSQL_ROOT_PASSWORD
fi
apachectl -DFOREGROUND
