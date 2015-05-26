run_postfixadmin_server(){
    local DOMAIN_NAME=$1
    local POSTFIXADMIN_MYSQL_PASSWD=$2
    local NGINX_PROXY=$3
    if [ $NGINX_PROXY -eq 1 ];then
        read -p "please, provide the virtualhost for accessing the postfixadmin container [postfixadmin.${DOMAIN_NAME}] :"
        local vhost=${REPLY:-"postfixadmin.$DOMAIN_NAME"}
        POSTFIX_ADMIN_VHOST="-e VIRTUAL_HOST=${vhost}"
    else
      read -p "Specify the interface to bind postfixadmin to [127.0.0.1] (use via ssh tunnel) :"
      local POSTFIXADMIN_INTERFACE=${REPLY:-"127.0.0.1"}

      read -p "Specify port which postfixadmin will listen to for HTTP connections [9090] :"
      local POSTFIXADMIN_PORT=${REPLY:-"9090"}
      POSTFIX_ADMIN_VHOST="-p ${POSTFIXADMIN_INTERFACE}:${POSTFIXADMIN_PORT}:80"
    fi
    read -p "please, Specify an admin account login [admin@${DOMAIN_NAME}] :"
    local ADMIN_LOGIN=${REPLY:-"admin@$DOMAIN_NAME"}

    while [ -z "$ADMIN_PASSWORD" ]||[ ${#ADMIN_PASSWORD} -lt 12 ];do
        read -p "Please, provide a password for your admin account with at least 12 chars:"
        local ADMIN_PASSWORD=$REPLY
    done

    echo "starting postfixadmin container..."
    docker run -d \
    --name dockermail_postfixadmin \
    --link dockermail_mysql:mysql \
    --link dockermail_dovecot:dovecot \
    -e ADMIN_PASSWORD=$ADMIN_PASSWORD \
    -e ADMIN_LOGIN=$ADMIN_LOGIN \
    -e DB_NAME=postfixadmin \
    -e DB_USER=postfixadmin \
    -e DB_PASSWD=$POSTFIXADMIN_MYSQL_PASSWD \
    $POSTFIX_ADMIN_VHOST \
    -e DOMAIN=$DOMAIN_NAME \
    dockermail/postfixadmin
    echo "postfixadmin started !"
}
