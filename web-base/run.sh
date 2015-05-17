#!/bin/sh
if [ ! -e /root/configured/is_done ];then
  . /root/on_first_run.sh
  echo "yes">/root/configured/is_done
fi
. /root/on_run.sh
apachectl -DFOREGROUND
