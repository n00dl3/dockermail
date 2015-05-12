#!/bin/sh
exec 2>&1
INPUT=/root/dovecot/dovecot-sql.conf.ext
OUTPUT=/etc/dovecot/dovecot-sql.conf.ext
sed -e "s/@db_user@/$DB_USER/g" -e "s/@db_name@/$DB_NAME/g" -e "s/@db_password@/$DB_PASSWD/g" $INPUT > $OUTPUT
chown -R vmail:vmail /srv/ssl
exec dovecot \
-F
