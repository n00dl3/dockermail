#!/bin/sh
exec 2>&1
sv start /.runit/services/syslogd || exit 1
sv start /.runit/services/klogd || exit 1
killall -v -9 dovecot
exec dovecot \
-F
