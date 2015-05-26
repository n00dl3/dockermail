
run_roundcube_server(){
    local DOMAIN_NAME=$1
    local ROUNDCUBE_MYSQL_PASSWD=$2
    local NGINX_PROXY=$3
    #configure run variables
    if [ $NGINX_PROXY -eq 1 ];then
        read -p "please, provide the virtualhost for accessing the roundcube container [roundcube.${DOMAIN_NAME}] :"
        local vhost=${REPLY:-"roundcube.$DOMAIN_NAME"}
        local ROUNDCUBE_VHOST="-e VIRTUAL_HOST=$vhost"
    else
      read -p "Specify the interface to bind roundcube to [0.0.0.0] :"
      local ROUNDCUBE_INTERFACE=${REPLY:-"0.0.0.0"}

      read -p "Specify port which roundcube will listen to for HTTP connections [8080] :"
      local ROUNDCUBE_PORT=${REPLY:-"8080"}

     local  ROUNDCUBE_VHOST="-p ${ROUNDCUBE_INTERFACE}:${ROUNDCUBE_PORT}:80"
    fi

    echo "building roundcube container...."
    docker run -d \
    --name dockermail_roundcube \
    -e DB_NAME=roundcube \
    -e DB_USER=roundcube \
    -e DB_PASSWD=$ROUNDCUBE_MYSQL_PASSWD \
    $ROUNDCUBE_VHOST \
    --link dockermail_mysql:mysql \
    --link dockermail_dovecot:dovecot \
    dockermail/roundcube
    echo "Done !"
}
