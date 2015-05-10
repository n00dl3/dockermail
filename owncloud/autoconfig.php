<?php
$adminlogin=getenv('ADMIN_LOGIN')?getenv('ADMIN_LOGIN'):"admin";
$adminpass=getenv('ADMIN_PASSWORD')?getenv('ADMIN_PASSWORD'):"admin";
$AUTOCONFIG = array(
  "dbtype"        => "sqlite",
  "adminlogin"    => $adminlogin,
  "adminpass"     => $adminpass,
  "directory"     => "/var/www/owncloud/data",
);
