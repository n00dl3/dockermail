#!/bin/sh
mysql -u$DB_USER -p$DB_PASSWD --host=mysql $DB_NAME < /root/database.sql
