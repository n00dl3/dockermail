<?php
$AUTOCONFIG = array(
  "dbtype"        => "mysql",
  "dbname"        => getenv("DB_NAME"),
  "dbuser"        => getenv("DB_USER"),
  "dbpass"        => getenv("DB_PASSWD"),
  "dbhost"        => "mysql",
  "dbtableprefix" => "",
  "adminlogin"    => getenv('ADMIN_LOGIN')?getenv('ADMIN_LOGIN'):"admin",
  "adminpass"     => getenv('ADMIN_PASSWD')?getenv('ADMIN_PASSWD'):"admin",
  "directory"     => "/var/www/owncloud/data",
);
