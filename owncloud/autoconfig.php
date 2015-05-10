<?php
$adminlogin=get_env('ADMIN_LOGIN')?get_env('ADMIN_LOGIN'):"admin";
$adminpass=get_env('ADMIN_PASSWORD')?get_env('ADMIN_PASSWORD'):"admin";
$AUTOCONFIG = array(
  "dbtype"        => "sqlite",
  "adminlogin"    => $adminlogin,
  "adminpass"     => $adminpass,
  "directory"     => "/var/www/owncloud/data",
);
