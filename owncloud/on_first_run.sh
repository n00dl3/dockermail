#!/bin/sh
cd /var/www/ && su - www-data -c "php5 index.php"
php5 /var/www/occ app:enable user_external
chown -R www-data:www-data /var/www/
