#!/bin/bash
DIR=`ls /var/www/html/data/_data_* -d`
IN=$DOMAINS
arr=$(echo $IN | tr ";" "\n")

for i in $arr;
 do echo "\
imap_host = \"$i\"
imap_port = 143
imap_secure = \"TLS\"
smtp_host = \"$i\"
smtp_port = 587
smtp_secure = \"TLS\"
smtp_auth = On" > $DIR/_default_/domains/$i.ini;
chown www-data:www-data $DIR/_default_/domains/$i.ini;
done;
