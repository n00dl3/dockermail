run_mail_server(){
    stop_container dovecot
    if [ $? -gt 0 ];then
      return 2
    fi
    local INSTALL_PATH=$1
    local POSTFIXADMIN_MYSQL_PASSWD=$2
    local DOVECOT_PORT_BINDING=""
    local DOVECOT_CERTS_PATH="$INSTALL_PATH/dovecot/certs"
    local DOVECOT_MAIL_PATH="$INSTALL_PATH/dovecot/mails"
    #create directories
    if [ ! -d "$DOVECOT_CERTS_PATH" ];then
      mkdir -p $DOVECOT_CERTS_PATH
    fi
    if [ ! -d "$DOVECOT_MAIL_PATH" ];then
      mkdir -p $DOVECOT_MAIL_PATH
    fi
    #read port bindings
    read -r -p "Specify the interface to bind the mail server to [0.0.0.0] :"
    local DOVECOT_INTERFACE=${REPLY:-"0.0.0.0"}

    read -r -p "Specify the port for imap connections (TLS) [143] :"
    local IMAP_PORT=${REPLY:-"143"}

    read -r -p "Specify the port for imap connections (SSL) [993] :"
    local IMAPS_PORT=${REPLY:-"993"}

    read -r -p "Specify the port for incoming smtp connections [25] :"
    local SMTP_IN=${REPLY:-"25"}

    read -r -p "Specify the port for outgoing smtp connections [587] :"
    local SMTP_OUT=${REPLY:-"587"}

    DOVECOT_PORT_BINDING="-p ${DOVECOT_INTERFACE}:${IMAP_PORT}:143 -p ${DOVECOT_INTERFACE}:${IMAPS_PORT}:993 -p ${DOVECOT_INTERFACE}:${SMTP_IN}:25  -p ${DOVECOT_INTERFACE}:${SMTP_OUT}:587"
    #start container
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
}
