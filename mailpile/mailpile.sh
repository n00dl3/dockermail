#!/bin/sh
exec 2>&1
/etc/mailpile/mp --www=0.0.0.0:33411 --wait
