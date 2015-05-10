#!/bin/sh
exec 2>&1
chown -R www-data:www-data /var/www/owncloud/data
a2enmod rewrite
php5enmod imap
apachectl -DFOREGROUND
