#!/bin/bash
source ./brainless_installer/commons.sh
source ./brainless_installer/mail_server.sh
source ./brainless_installer/mysql.sh
source ./brainless_installer/nginx-proxy.sh
source ./brainless_installer/owncloud.sh
source ./brainless_installer/postfixadmin.sh
source ./brainless_installer/roundcube.sh

read -r -p "please, provide your main domain name :"    DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ];then
  echo "no domain name specified, aborting..."
  exit 2
fi

COUNTRY=""
while [ ${#COUNTRY} -ne 2 ];do
    echo "(if you don't know, see https://www.iso.org/obp/ to find the relevant one)"
    read -r -p "please, provide your 2 letter country-code : "  -n 2 COUNTRY
    echo
done

read -r -p "please, provide the address of your server [mail.${DOMAIN_NAME}] : "
MAIL_DOMAIN=${REPLY:-"mail.$DOMAIN_NAME"}

read -r -p "please provide your state code (if any) :" STATE

read -r -p "please provide the city :" CITY

read -r -p "please, provide an optional company name :" ORGANIZATION

read -r -p "please, provide an install path for dockermail [/opt/dockermail]"
INSTALL_PATH=${REPLY:-"/opt/dockermail"}
if [ ! -d $INSTALL_PATH ];then
  mkdir $INSTALL_PATH
fi

read -r -p "stop and remove every running dockermail containers ? [Y/n]" -n 1 REMOVE
echo
if [ "$REMOVE" != "n" ] && [ "$REMOVE" != "N" ];then
  docker ps | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker stop
  docker ps -a | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker rm -v
  echo "done"
fi

read -r -p "remove all dockermail images ? [Y/n]" -n 1 REMOVE
echo
if [ "$REMOVE" != "n" ] && [ "$REMOVE" != "N" ];then
  docker images | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker rmi
  echo "done"
fi

build_image web-base
build_image mysql
build_image postfixadmin
build_image dovecot

echo "Use (the awesome) Jason Wilder's nginx-proxy ? [Y/n]"
echo "see https://github.com/jwilder/nginx-proxy for further informations..."
read -n 1 NGINX_PROXY
echo
if [ "$NGINX_PROXY" != "n" ] && [ "$NGINX_PROXY" != "N" ];then
  NGINX_PROXY=1
  run_nginx_proxy $INSTALL_PATH
else
  NGINX_PROXY=0
fi

POSTFIXADMIN_MYSQL_PASSWD=$(RandomString 32)
ROUNDCUBE_MYSQL_PASSWD=$(RandomString 32)
OWNCLOUD_MYSQL_PASSWD=$(RandomString 32)

# run mysql server
run_mysql_server $POSTFIXADMIN_MYSQL_PASSWD $OWNCLOUD_MYSQL_PASSWD $ROUNDCUBE_MYSQL_PASSWD
#    run Dovecot
run_mail_server $INSTALL_PATH $POSTFIXADMIN_MYSQL_PASSWD
# run postfixadmin
run_postfixadmin_server $DOMAIN_NAME $POSTFIXADMIN_MYSQL_PASSWD $NGINX_PROXY
###################
# run roundcube
###################
read -r -p "would you like to run roundcube container ? [y/N]" -n 1 BUILD_ROUNDCUBE
echo
if [ "$BUILD_ROUNDCUBE" == "Y" ] || [ "$BUILD_ROUNDCUBE" == "y" ];then
    build_image "roundcube"
    run_roundcube_server $DOMAIN_NAME ROUNDCUBE_MYSQL_PASSWD $NGINX_PROXY
fi

##########################################
# run owncloud
##########################################

read -r -p "Would you like to run owncloud container ? [y/N]" -n 1 BUILD_OWNCLOUD
echo
if [ "$BUILD_OWNCLOUD" == "Y" ] || [ "$BUILD_OWNCLOUD" == "y" ];then
    build_image "owncloud"
  run_owncloud_server $DOMAIN_NAME $OWNCLOUD_MYSQL_PASSWD $NGINX_PROXY $INSTALL_PATH
fi
