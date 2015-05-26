#!/bin/bash
source ./brainless_installer/commons.sh
source ./brainless_installer/mail_server.sh
source ./brainless_installer/mysql.sh
source ./brainless_installer/nginx-proxy.sh
source ./brainless_installer/owncloud.sh
source ./brainless_installer/postfixadmin.sh
source ./brainless_installer/roundcube.sh

echo "please, provide your main domain name :"
read DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ];then
  echo "no domain name specified, aborting..."
  exit 2
fi

COUNTRY=""
while [ ${#COUNTRY} -ne 2 ];do
    echo "please, provide your 2 letter country-code :"
    echo "(if you don't know, see https://www.iso.org/obp/ to find the relevant one)"
    read COUNTRY
done

echo "please provide your state code (if any) :"
read STATE

echo "please provide the city :"
read CITY

echo "please, provide an optional company name :"
read COMPANY

OPENSSL_SUBJ="/C=$COUNTRY"
if [ ! -z "$STATE" ];then
    OPENSSL_SUBJ="$OPENSSL_SUBJ/ST=$STATE"
fi
if [ ! -z "$CITY" ];then
    OPENSSL_SUBJ="$OPENSSL_SUBJ/L=$CITY"
fi
if [ ! -z "COMPANY" ];then
    OPENSSL_SUBJ="$OPENSSL_SUBJ/O=$COMPANY"
fi


read -p "please, provide an install path for dockermail [/opt/dockermail]"
INSTALL_PATH=${REPLY:-"/opt/dockermail"}
if [ ! -d $INSTALL_PATH ];then
  mkdir $INSTALL_PATH
fi

read -p "stop and remove every running dockermail containers ? [Y/n]" REMOVE
if [ "$REMOVE" != "n" ] && [ "$REMOVE" != "N" ];then
  docker ps | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker stop
  docker ps -a | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker rm -v
  echo "done"
fi

read -p "remove all dockermail images ? [Y/n]" REMOVE
if [ "$REMOVE" != "n" ] && [ "$REMOVE" != "N" ];then
  docker images | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker rmi
  echo "done"
fi
images=("web-base" "mysql" "postfixadmin" "dovecot")
for image in images; do
    build_image $image
done

echo "Use (the awesome) Jason Wilder's nginx-proxy ? [Y/n]"
echo "see https://github.com/jwilder/nginx-proxy for further informations..."
read NGINX_PROXY
if [ "$NGINX_PROXY" != "n" ] && [ "$NGINX_PROXY" != "N" ];then
  NGINX_PROXY=1
  run_nginx_proxy $INSTALL_PATH
else
  NGINX_PROXY=0
fi

POSTFIXADMIN_MYSQL_PASSWD=$(RandomString 32)
ROUNDCUBE_MYSQL_PASSWD=$(RandomString 32)
OWNCLOUD_MYSQL_PASSWD=$(RandomString 32)
#############################################
# run mysql server
############################################
run_mysql_server $POSTFIXADMIN_MYSQL_PASSWD $OWNCLOUD_MYSQL_PASSWD $ROUNDCUBE_MYSQL_PASSWD
#############################################
#    run Dovecot
############################################
run_mail_server $INSTALL_PATH $POSTFIXADMIN_MYSQL_PASSWD

###########################################
# run postfixadmin
###########################################
run_postfixadmin_server $DOMAIN_NAME $POSTFIXADMIN_MYSQL_PASSWD $NGINX_PROXY
###########################################
# run roundcube
###########################################
echo "would you like to run roundcube container ? [y/N]"
read BUILD_ROUNDCUBE
if [ "$BUILD_ROUNDCUBE" == "Y" ] || [ "$BUILD_ROUNDCUBE" == "y" ];then
    build_image "roundcube"
    run_roundcube_server $DOMAIN_NAME ROUNDCUBE_MYSQL_PASSWD $NGINX_PROXY
fi
##########################################
# run owncloud
##########################################

echo "Would you like to run owncloud container ? [y/N]"
read BUILD_OWNCLOUD
if [ "$BUILD_OWNCLOUD" == "Y" ] || [ "$BUILD_OWNCLOUD" == "y" ];then
    build_image "owncloud"
  run_owncloud_server $DOMAIN_NAME $OWNCLOUD_MYSQL_PASSWD $NGINX_PROXY $INSTALL_PATH
fi
