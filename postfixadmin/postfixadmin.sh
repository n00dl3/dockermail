#!/bin/sh
exec 2>&1
php5enmod imap
if [ ! -e /root/configured ];then
  if [ -z $DB_NAME ];then
    echo "DB_NAME is not set"
    exit 2
  fi
  if [ -z $DB_USER ];then
    echo "DB_USER is not set"
    exit 2
  fi
  if [ -z $DB_PASSWD]; then
    echo "DB_PASSWD is not set"
    exit 2
  fi
  mysql -u$DB_USER -p$DB_PASSWD --host=mysql $DB_NAME < /root/database.sql
  touch /root/configured
  unset MYSQL_ROOT_PASSWORD
fi
apachectl -DFOREGROUND
