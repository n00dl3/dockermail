#!/bin/sh
exec 2>&1
php5enmod imap
apachectl -DFOREGROUND
