#!/bin/bash
echo $DOMAIN > /etc/mailname
for file in /root/postfix/*
do
  filename=$(basename $file)
  if [ filename!="." ]&&[ filename!=".." ];then
    sed -e "s/@db_user@/$DB_USER/g" -e "s/@db_name@/$DB_NAME/g" -e "s/@db_password@/$DB_PASSWD/g" -e "s/@domain@/$DOMAIN/g" $file > /etc/postfix/$filename
  fi
done

# make consistency check
postfix check 2>&1
# run Postfix
exec postfix start -v 2>&1
