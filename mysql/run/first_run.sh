#!/bin/bash
######################
#### POSTFIXADMIN ####
######################
if [ -z $POSTFIXADMIN_DB ];then
    POSTFIXADMIN_DB="postfixadmin"
fi
if [ -z $POSTFIXADMIN_USER ];then
    POSTFIXADMIN_USER="postfixadmin"
fi
if [ -z $POSTFIXADMIN_PASSWD ];then
    POSTFIXADMIN_PASSWD="password"
    echo "\033[1;33m**WARNING**\033[0m POSTFIXADMIN_PASSWD is not set, using default password: 'password'"
fi
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE '$POSTFIXADMIN_DB' DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON '$POSTFIXADMIN_DB'.* TO '$POSTFIXADMIN_USER'@'%' IDENTIFIED BY '$POSTFIXADMIN_PASSWD';"
######################
##### ROUND CUBE #####
######################
if [ -z $ROUNDCUBE_DB ];then
    ROUNDCUBE_DB="roundcube"
fi
if [ -z $ROUNDCUBE_USER ];then
    ROUNDCUBE_USER="roundcube"
fi
if [ -z $ROUNDCUBE_PASSWD ];then
    ROUNDCUBE_PASSWD="password"
    echo "\033[1;33m**WARNING**\033[0m ROUNDCUBE_PASSWD is not set, using default password: 'password'"
fi
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE '$ROUNDCUBE_DB' DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON '$ROUNDCUBE_DB'.* TO '$ROUNDCUBE_USER'@'%' IDENTIFIED BY '$ROUNDCUBE_PASSWD';"
######################
###### OWNCLOUD ######
######################
if [ -z $OWNCLOUD_DB ];then
    OWNCLOUD_DB="owncloud"
fi
if [ -z $OWNCLOUD_USER ];then
    OWNCLOUD_USER="owncloud"
fi
if[ -z $OWNCLOUD_PASSWD ];then
    OWNCLOUD_PASSWD="password"
    echo "\033[1;33m**WARNING**\033[0m OWNCLOUD_PASSWD is not set, using default password: 'password'"
fi

mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE '$OWNCLOUD_DB' DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON '$OWNCLOUD_DB'.* TO '$OWNCLOUD_DB'@'%' IDENTIFIED BY '$OWNCLOUD_PASSWD';"
