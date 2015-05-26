run_mysql_server(){
    POSTFIXADMIN_MYSQL_PASSWD=$1
    OWNCLOUD_MYSQL_PASSWD=$2
    ROUNDCUBE_MYSQL_PASSWD=$3
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
    echo -n "waiting for mysql container to be fully loaded..."
    while [ -z "$STARTED" ];do
        STARTED=$(docker logs dockermail_mysql |grep "ready for connections")
        echo -n "."
        sleep 2
    done
    echo "."
}
