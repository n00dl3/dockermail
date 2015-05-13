#!/bin/bash
echo $DOMAIN > /etc/mailname
for file in /root/postfix/*
do
  filename=$(basename $file)
  if [ filename!="." ]&&[ filename!=".." ]
    sed -e "s/@db_user@/$DB_USER/g" -e "s/@db_name@/$DB_NAME/g" -e "s/@db_password@/$DB_PASSWD/g" -e "s/@domain@/$DOMAIN/g" $file > /etc/postfix/$filename
  fi
done
command_directory=`postconf -h command_directory`
daemon_directory=`$command_directory/postconf -h daemon_directory`
# make consistency check
$command_directory/postfix check 2>&1
# run Postfix
exec $daemon_directory/master 2>&1
