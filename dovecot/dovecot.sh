#!/bin/sh
exec 2>&1
INPUT=/root/dovecot/dovecot-sql.conf.ext
OUTPUT=/etc/dovecot/dovecot-sql.conf.ext
for file in /root/dovecot/conf.d/*
do
  filename=$(basename $file)
  if [ filename!="." ]&&[ filename!=".." ];then
    sed -e "s/@db_user@/$DB_USER/g" -e "s/@domain@/$DOMAIN/g" -e "s/@db_name@/$DB_NAME/g" -e "s/@db_password@/$DB_PASSWD/g" $file > /etc/dovecot/conf.d/$filename
  fi
done
sed -e "s/@db_user@/$DB_USER/g" -e "s/@db_name@/$DB_NAME/g" -e "s/@domain@/$DOMAIN/g" -e "s/@db_password@/$DB_PASSWD/g" $INPUT > $OUTPUT
chown -R vmail:vmail /srv/ssl
exec dovecot \
-F
