
run_owncloud_server(){
    stop_container owncloud
    if [ $? -gt 0 ];then
      return 2
    fi
    build_image "owncloud"
    local DOMAIN_NAME=$1
    local OWNCLOUD_MYSQL_PASSWD=$2
    local NGINX_PROXY=$3
    local INSTALL_PATH=$4
    local host_binding=""
    if [ -d $OWNCLOUD_DATA_PATH ];then
      mkdir -p $OWNCLOUD_DATA_PATH
    fi
    #configure run variables
    if [ $NGINX_PROXY -eq 1 ];then
      read -r -p "please, provide the virtualhost for accessing the owncloud container [owncloud.${DOMAIN_NAME}] :"
      local v_host=${REPLY:-"owncloud.$DOMAIN_NAME"}
      host_binding="-e VIRTUAL_HOST=${v_host}"
    else
      read -r -p  "Specify the interface to bind owncloud to [0.0.0.0] :"
      local OWNCLOUD_INTERFACE=${REPLY:-"0.0.0.0"}

      read -r -p "Specify port which owncloud will listen to for HTTP connections [7070] :"
      local OWNCLOUD_PORT=${REPLY:-"7070"}

      host_binding="-p ${OWNCLOUD_INTERFACE}:${OWNCLOUD_PORT}:80"
    fi

    read -r -p "please, provide an admin login for your owncloud installation [admin] :"
    local OWNCLOUD_ADMIN_USER=${REPLY:-"admin"}

    local OWNCLOUD_ADMIN_PASSWORD=""
    while [ ${#OWNCLOUD_ADMIN_PASSWORD} -lt 12 ];do
        read -r -p "please, provide an admin password for your owncloud installation :" OWNCLOUD_ADMIN_PASSWORD
    done
    echo "building owncloud container..."
    docker run -d \
    --name dockermail_owncloud \
    -v $OWNCLOUD_DATA_PATH:/var/www/owncloud/data \
    -e DB_NAME=owncloud \
    -e DB_USER=owncloud \
    -e DB_PASSWD=$OWNCLOUD_MYSQL_PASSWD \
    -e ADMIN_LOGIN=$OWNCLOUD_ADMIN_USER \
    -e ADMIN_PASSWD=$OWNCLOUD_MYSQL_PASSWD \
    $host_binding \
    --link dockermail_mysql:mysql \
    dockermail/owncloud
    echo "Done!"
}
