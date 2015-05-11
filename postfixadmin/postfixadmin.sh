#!/bin/sh
exec 2>&1
php5enmod imap
if [ ! -e /root/configured ];then
  if [ -z $DB_NAME ] || [ -z $DB_USER ] || [ -z $DB_PASSWD ];then
    echo "you should set every environment variables to run this container"
  fi
  SQL="CREATE DATABASE $DB_NAME; GRANT ALL ON $DB_NAME.* to '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWD';"
  mysql -uroot -p$MYSQL_ROOT_PASSWORD -h mysql -e $SQL
  touch /root/configured
  unset MYSQL_ROOT_PASSWORD
fi
apachectl -DFOREGROUND
