#!/bin/bash
IN=$DOMAINS

arr=$(echo $IN | tr ";" "\n")

for domain in $arr
do
    echo "$domain\n">/etc/postfix/virtual-mailbox-domains
done
