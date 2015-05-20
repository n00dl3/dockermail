#!/bin/sh
RandomString(){
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-$1};echo;
}

if [ -z "$(docker images | grep dockermail/web-base)" ];then
  echo "creating web-base image..."
  cd ./web-base && docker build . -t dockermail/web-base
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/mysql)" ];then
  echo "creating MySQL image..."
  cd ./mysql && docker build . -t dockermail/mysql
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/postfixadmin)" ];then
  echo "building Postfixadmin image..."
  cd ./postfixadmin && docker build . -t dockermail/postfixadmin
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/owncloud)" ];then
  echo "building Postfixadmin image..."
  cd ./owncloud && docker build . -t dockermail/owncloud
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/roundcube)" ];then
  echo "building Roundcube image..."
  cd ./roundcube && docker build . -t dockermail/roundcube
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/dovecot)" ];then
  echo "building Dovecot image..."
  cd ./dovecot && docker build . -t dockermail/dovecot
  echo "Done !"
fi


source ./vars.sh
if [ -z "$MYSQL_CONTAINER_NAME" ];then
  echo "MySQL Container name [mysql]:"
  read MYSQL_CONTAINER_NAME
  if [ -z "$MYSQL_CONTAINER_NAME" ];then
    MYSQL_CONTAINER_NAME="mysql"
  fi
fi
if [ -z "$MYSQL_POSTFIXADMIN_PASSWD" ];then
  echo "Postfixadmin mysql password [mysql]:"
  read MYSQL_CONTAINER_NAME
  if [ -z "$MYSQL_CONTAINER_NAME" ];then
    MYSQL_CONTAINER_NAME="mysql"
  fi
fi
POSTFIXADMIN_MYSQL_PASSWD=RandomString 32
ROUNDCUBE_MYSQL_PASSWD=RandomString 32
OWNCLOUD_MYSQL_PASSWD=RandomString 32

docker run --name $MYSQL_CONTAINER_NAME \
-e POSTFIXADMIN_DB=dockermail_postfixadmin \
-e POSTFIXADMIN_USER=dockermail_postfixadmin\
dockermail/mysql
if [ -z ]
