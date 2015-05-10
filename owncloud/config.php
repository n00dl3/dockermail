<?php

$domains=explode(";",get_env("DOMAINS"));

$arguments=array();

foreach($domains as $domain){
  $arguments[]='{'.$domain.':143/imap/tls/novalidate-cert}INBOX';
}

$CONFIG = array(
'overwritehost' => get_env('PUBLIC_URL'),
'check_for_working_webdav' => false,
'dbtype' => 'sqlite',

'user_backends'=>array(
	array(
		'class' => 'OC_User_IMAP',
		'arguments' => $arguments
	)
)

);
