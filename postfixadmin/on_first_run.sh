#!/bin/sh
PASSWORD_HASH=$(echo "$ADMIN_PASSWORD"|openssl passwd -1 -stdin)
sed -e "s/@@admin_login@@/$ADMIN_LOGIN/g" -e "s/@@password_hash@@/$PASSWORD_HASH/g" /root/database.sql.tpl > /root/database.sql
chmod 700 /root/database.sql
mysql -u$DB_USER -p$DB_PASSWD --host=mysql $DB_NAME < /root/database.sql
