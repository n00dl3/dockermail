#!/bin/bash
command_directory=`postconf -h command_directory`
daemon_directory=`$command_directory/postconf -h daemon_directory`
# make consistency check
$command_directory/postfix check 2>&1
# run Postfix
exec $daemon_directory/master 2>&1
