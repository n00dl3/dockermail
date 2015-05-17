<?php

$CONFIG = array(
'overwritehost' => getenv('PUBLIC_URL'),
'check_for_working_webdav' => false,
'dbtype' => 'mysql',
"dbname"        => getenv("DB_NAME"),
"dbuser"        => getenv("DB_USER"),
"dbpass"        => getenv("DB_PASSWD"),
"dbhost"        => "mysql",
"dbtableprefix" => "",
'user_backends'=>array(
	array(
		'class' => 'OC_User_IMAP',
		'arguments' => array('{dovecot:143/imap/tls/novalidate-cert}INBOX')
	)
)

);
