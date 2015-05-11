#!/bin/sh
exec 2>&1
php5enmod imap
if [ ! -e /root/configured ];then
  if [ -z $MYSQL_ROOT_PASSWORD ] || [ -z $DB_NAME ] || [ -z $DB_USER ] || [ -z $DB_PASSWD ];then
    echo "you should set every environment variables to run this container"
    exit 2
  fi
  mysql -uroot -p$MYSQL_ROOT_PASSWORD --host=mysql -e "$SQL"
  touch /root/configured
  unset MYSQL_ROOT_PASSWORD
fi
apachectl -DFOREGROUND
