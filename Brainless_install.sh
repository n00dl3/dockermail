#!/bin/bash
RandomString(){
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-$1};echo;
}
echo "please, provide your main domain name :"
read DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ];then
  echo "no domain name specified, aborting..."
  exit 2
fi

echo "please, provide an install path for dockermail [/opt/dockermail]"
read INSTALL_PATH
if [ -z "$INSTALL_PATH" ];then
  INSTALL_PATH=/opt/dockermail
fi
if [ ! -d $INSTALL_PATH ];then
  mkdir $INSTALL_PATH
fi

echo "stop and remove every running dockermail containers ? [Y/n]"
read REMOVE
if [ "$REMOVE" != "n" ] && [ "$REMOVE" != "N" ];then
  docker ps | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker stop
  docker ps -a | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker rm -v
  echo "done"
fi

echo "remove all dockermail images (existing images won't be built)? [Y/n]"
read REMOVE
if [ "$REMOVE" != "n" ] && [ "$REMOVE" != "N" ];then
  docker images | grep dockermail | awk '{print $1}' | xargs --no-run-if-empty docker rmi
  echo "done"
fi

if [ -z "$(docker images | grep dockermail/web-base)" ];then
  echo "creating web-base image..."
  cd ./web-base && docker build -t dockermail/web-base . && cd ..
  echo $PWD
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/mysql)" ];then
  echo "creating MySQL image..."
  cd ./mysql && docker build -t dockermail/mysql . && cd ..
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/postfixadmin)" ];then
  echo "building Postfixadmin image..."
  cd ./postfixadmin && docker build -t dockermail/postfixadmin . && cd ..
  echo "Done !"
fi

if [ -z "$(docker images | grep dockermail/dovecot)" ];then
  echo "building Dovecot image..."
  cd ./dovecot && docker build -t dockermail/dovecot . && cd ..
  echo "Done !"
fi

echo "Use (the awesome) Jason Wilder's nginx-proxy ? [Y/n]"
echo "see https://github.com/jwilder/nginx-proxy for further informations..."
read NGINX_PROXY
if [ "$NGINX_PROXY" != "n" ] && [ "$NGINX_PROXY" != "N" ];then
  NGINX_PROXY=1
  NGINX_PATH="$INSTALL_PATH/nginx"
  NGINX_CERT_PATH="$NGINX_PATH/certs"
  NGINX_TPL_PATH="$NGINX_PATH/tpl"
  if [ ! -d "$NGINX_CERT_PATH" ];then
    echo "creating folder $NGINX_CERT_PATH"
    mkdir -p $NGINX_PATH
  fi
  if [ ! -d "$NGINX_TPL_PATH" ];then
    echo "creating folder $NGINX_TPL_PATH"
    mkdir -p $NGINX_TPL_PATH
  fi
  if [ ! -f "$NGINX_TPL_PATH/nginx.tmpl" ];then
    "echo downloading nginx.tmpl..."
    wget -O $NGINX_TPL_PATH/nginx.tmpl --no-check-certificate https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl
  fi
  echo "starting nginx container"
  docker run -d \
  --name dockermail_nginx \
  -p 80:80 \
  -p 443:443 \
  -v $NGINX_CERT_PATH:/etc/nginx/certs \
  -v /tmp/nginx:/etc/nginx/conf.d \
  nginx
  echo "nginx container started"
  echo "starting docker-gen container..."
  docker run -d \
  --volumes-from dockermail_nginx \
  --name dockermail_docker_gen \
  -v /var/run/docker.sock:/tmp/docker.sock \
  -v $NGINX_TPL_PATH:/etc/docker-gen/templates \
  -t jwilder/docker-gen -notify-sighup dockermail_nginx -watch -only-exposed /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
  echo "done"
else
  NGINX_PROXY=0
fi



POSTFIXADMIN_MYSQL_PASSWD=$(RandomString 32)
ROUNDCUBE_MYSQL_PASSWD=$(RandomString 32)
OWNCLOUD_MYSQL_PASSWD=$(RandomString 32)
echo "starting mysql container..."
docker run -d \
--name dockermail_mysql \
-e POSTFIXADMIN_DB=postfixadmin \
-e POSTFIXADMIN_USER=postfixadmin \
-e POSTFIXADMIN_PASSWD=$POSTFIXADMIN_MYSQL_PASSWD \
-e OWNCLOUD_PASSWD=$OWNCLOUD_MYSQL_PASSWD \
-e OWNCLOUD_USER=owncloud \
-e OWNCLOUD_DB=owncloud \
-e ROUNDCUBE_USER=roundcube \
-e ROUNDCUBE_DB=roundcube \
-e ROUNDCUBE_PASSWD=$ROUNDCUBE_MYSQL_PASSWD \
dockermail/mysql
echo "mysql container started !"
echo "Specify the interface to bind the mail server to [0.0.0.0] :"
read DOVECOT_INTERFACE
if [ -z "$DOVECOT_INTERFACE" ];then
  DOVECOT_INTERFACE="0.0.0.0"
fi
echo "Specify the port for imap connections (TLS) [143] :"
read IMAP_PORT
if [ -z "$IMAP_PORT" ];then
  IMAP_PORT="143"
fi
DOVECOT_PORT_BINDING="-p ${DOVECOT_INTERFACE}:${IMAP_PORT}:143"
echo "Specify the port for imap connections (SSL) [993] :"
read IMAPS_PORT
if [ -z "$IMAPS_PORT" ];then
  IMAPS_PORT="993"
fi
DOVECOT_PORT_BINDING="${DOVECOT_PORT_BINDING} -p ${DOVECOT_INTERFACE}:${IMAPS_PORT}:993"

echo "Specify the port for incoming smtp connections [25] :"
read SMTP_IN
if [ -z "$SMTP_IN" ];then
  SMTP_IN="25"
fi
DOVECOT_PORT_BINDING="${DOVECOT_PORT_BINDING} -p ${DOVECOT_INTERFACE}:${SMTP_IN}:25"

echo "Specify the port for outgoing smtp connections [587] :"
read SMTP_OUT
if [ -z "$SMTP_OUT" ];then
  SMTP_OUT="587"
fi
DOVECOT_PORT_BINDING="${DOVECOT_PORT_BINDING} -p ${DOVECOT_INTERFACE}:${SMTP_OUT}:587"

DOVECOT_CERTS_PATH="$INSTALL_PATH/dovecot/certs"
DOVECOT_MAIL_PATH="$INSTALL_PATH/dovecot/mails"
if [ ! -d "$DOVECOT_CERTS_PATH" ];then
  mkdir -p $DOVECOT_CERTS_PATH
fi
if [ ! -d "$DOVECOT_MAIL_PATH" ];then
  mkdir -p $DOVECOT_MAIL_PATH
fi
echo "starting mail server container..."
docker run -d \
 --name dockermail_dovecot \
-e DB_NAME=postfixadmin \
-e DB_USER=postfixadmin \
-e DB_PASSWD=$POSTFIXADMIN_MYSQL_PASSWD \
$DOVECOT_PORT_BINDING \
-e DOMAIN=$DOMAIN_NAME \
-v $DOVECOT_CERTS_PATH:/srv/ssl \
-v $DOVECOT_MAIL_PATH:/srv/vmail \
--link dockermail_mysql:mysql \
dockermail/dovecot
echo "mail server started !"

if [ $NGINX_PROXY -eq 1 ];then
  echo "please, provide the virtualhost for accessing the postfixadmin container [postfixadmin.${DOMAIN_NAME}] :"
  read POSTFIX_ADMIN_VHOST
  if [ -z "$POSTFIX_ADMIN_VHOST" ];then
    POSTFIX_ADMIN_VHOST="-e VIRTUAL_HOST=postfixadmin.${DOMAIN_NAME}"
  else
    POSTFIX_ADMIN_VHOST="-e VIRTUAL_HOST=${POSTFIX_ADMIN_VHOST}"
  fi
  POSTFIXADMIN_PORT_BIND=""
else
  POSTFIX_ADMIN_VHOST=""
  echo "Specify the interface to bind postfixadmin to [127.0.0.1] (use via ssh tunnel) :"
  read POSTFIXADMIN_INTERFACE
  if [ -z "$POSTFIXADMIN_INTERFACE" ];then
    POSTFIXADMIN_INTERFACE="127.0.0.1"
  fi
  echo "Specify port which postfixadmin will listen to for HTTP connections [9090] :"
  read POSTFIXADMIN_PORT
  if [ -z "$POSTFIXADMIN_PORT" ];then
    POSTFIXADMIN_PORT="9090"
  fi
  POSTFIXADMIN_PORT_BIND="-p ${POSTFIXADMIN_INTERFACE}:${POSTFIXADMIN_PORT}:80"
fi

echo "starting postfixadmin container..."
docker run -d \
--name dockermail_postfixadmin \
--link dockermail_mysql:mysql \
--link dockermail_dovecot:dovecot \
-e DB_NAME=postfixadmin \
-e DB_USER=postfixadmin \
-e DB_PASSWD=$POSTFIXADMIN_MYSQL_PASSWD \
$POSTFIX_ADMIN_VHOST \
$POSTFIXADMIN_PORT_BIND \
-e DOMAIN=$DOMAIN_NAME \
dockermail/postfixadmin
echo "postfixadmin started !"

echo "would you like to run roundcube container ? [y/N]"
read BUILD_ROUNDCUBE
if [ "$BUILD_ROUNDCUBE" == "Y" ] || [ "$BUILD_ROUNDCUBE" == "y" ];then
  if [ -z "$(docker images | grep dockermail/roundcube)" ];then
    echo "building Roundcube image..."
    cd ./roundcube && docker build -t dockermail/roundcube . && cd ..
    echo "Done !"
  fi
  #configure run variables
  if [ $NGINX_PROXY -eq 1 ];then
    echo "please, provide the virtualhost for accessing the roundcube container [roundcube.${DOMAIN_NAME}] :"
    read ROUNDCUBE_VHOST
    if [ -z "$ROUNDCUBE_VHOST" ];then
      ROUNDCUBE_VHOST="-e VIRTUAL_HOST=roundcube.${DOMAIN_NAME}"
    else
      ROUNDCUBE_VHOST="-e VIRTUAL_HOST=${ROUNDCUBE_VHOST}"
    fi
    ROUNDCUBE_PORT_BIND=""
  else
    ROUNDCUBE_VHOST=""
    echo "Specify the interface to bind roundcube to [0.0.0.0] :"
    read ROUNDCUBE_INTERFACE
    if [ -z "$ROUNDCUBE_INTERFACE" ];then
      ROUNDCUBE_INTERFACE="0.0.0.0"
    fi
    echo "Specify port which roundcube will listen to for HTTP connections [8080] :"
    read ROUNDCUBE_PORT
    if [ -z "$ROUNDCUBE_PORT" ];then
      ROUNDCUBE_PORT="8080"
    fi
    ROUNDCUBE_PORT_BIND="-p ${ROUNDCUBE_INTERFACE}:${ROUNDCUBE_PORT}:80"
  fi
  echo "building roundcube container...."
  docker run -d \
  --name dockermail_roundcube \
  -e DB_NAME=roundcube \
  -e DB_USER=roundcube \
  -e DB_PASSWD=$ROUNDCUBE_MYSQL_PASSWD \
  $ROUNDCUBE_PORT_BIND \
  $ROUNDCUBE_VHOST \
  --link dockermail_mysql:mysql \
  --link dockermail_dovecot:dovecot \
  dockermail/roundcube
  echo "Done !"
fi

echo "Would you like to run owncloud container ? [y/N]"
read BUILD_OWNCLOUD
if [ "$BUILD_OWNCLOUD" == "Y" ] || [ "$BUILD_OWNCLOUD" == "y" ];then
  OWNCLOUD_DATA_PATH="$INSTALL_PATH/owncloud/data"
  if [ -z "$(docker images | grep dockermail/owncloud)" ];then
    echo "building Postfixadmin image..."
    cd ./owncloud && docker build -t dockermail/owncloud . && cd ..
    echo "Done !"
  fi
  if [ -d $OWNCLOUD_DATA_PATH ];then
    mkdir -p $OWNCLOUD_DATA_PATH
  fi
  #configure run variables
  if [ $NGINX_PROXY -eq 1 ];then
    echo "please, provide the virtualhost for accessing the owncloud container [owncloud.${DOMAIN_NAME}] :"
    read OWNCLOUD_VHOST
    if [ -z "$OWNCLOUD_VHOST" ];then
      OWNCLOUD_VHOST="-e VIRTUAL_HOST=owncloud.${DOMAIN_NAME}"
    else
      OWNCLOUD_VHOST="-e VIRTUAL_HOST=${OWNCLOUD_VHOST}"
    fi
    OWNCLOUD_PORT_BIND=""
  else
    OWNCLOUD_VHOST=""
    echo "Specify the interface to bind owncloud to [0.0.0.0] :"
    read OWNCLOUD_INTERFACE
    if [ -z "$OWNCLOUD_INTERFACE" ];then
      OWNCLOUD_INTERFACE="0.0.0.0"
    fi
    echo "Specify port which owncloud will listen to for HTTP connections [7070] :"
    read OWNCLOUD_PORT
    if [ -z "$OWNCLOUD_PORT" ];then
      OWNCLOUD_PORT="7070"
    fi
    OWNCLOUD_PORT_BIND="-p ${OWNCLOUD_INTERFACE}:${OWNCLOUD_PORT}:80"
  fi

  echo "building owncloud container..."
  docker run -d \
  --name dockermail_owncloud \
  -v $OWNCLOUD_DATA_PATH:/var/www/owncloud/data \
  -e DB_NAME=owncloud \
  -e DB_USER=owncloud \
  -e DB_PASSWORD=$OWNCLOUD_MYSQL_PASSWD \
  $OWNCLOUD_PORT_BIND \
  $OWNCLOUD_VHOST \
  --link dockermail_mysql:mysql \
  dockermail/owncloud
  echo "Done!"
fi
