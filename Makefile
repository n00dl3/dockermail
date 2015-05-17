all: mail-base dovecot rainloop owncloud

.PHONY: mail-base dovecot rainloop owncloud roundcube run-dovecot run-rainloop run-owncloud postfixadmin run-postfixadmin run-roundcube postfixadmin web-base

postfixadmin:
	cd postfixadmin; docker build -t dockermail/postfixadmin .

roundcube:
	cd roundcube; docker build -t dockermail/roundcube .

dovecot:
	cd dovecot; docker build -t dockermail/dovecot:2.1.7 .

rainloop:
	cd rainloop; docker build -t dockermail/rainloop:1.6.9 .

mailpile:
	cd mailpile; docker build -t dockermail/mailpile:latest .

owncloud:
	cd owncloud; docker build -t dockermail/owncloud:8.0.2 .

postfixadmin:
	cd postfixadmin; docker build -t dockermail/postfixadmin .
web-base:
	cd web-base; docker build -t dockermail/web-base .

run-roundcube:
	docker run -e VIRTUAL_HOST=roundcube.n00dl3.ovh -e DB_NAME=roundcubemail -e DB_USER=roundcube -e DB_PASSWD=password --link mysql:mysql --link dovecot:dovecot -d --name roundcube dockermail/roundcube

run-postfixadmin:
	docker run -e VIRTUAL_HOST=postfixadmin.n00dl3.ovh -e DB_NAME=postfixadmin -e DB_USER=postfix -e DB_PASSWD=password -e DOMAIN=n00dl3.ovh  --link dovecot:dovecot  --link mysql:mysql -d --name postfixadmin dockermail/postfixadmin:latest

run-dovecot:
	docker run -e DB_NAME=postfixadmin -e DB_USER=postfixadmin -e DB_PASSWD=password -e DOMAIN=n00dl3.ovh -v /srv/certs:/srv/ssl -d -v /srv/vmail:/srv/vmail --link mysql:mysql --name dovecot dockermail/dovecot:2.1.7

run-rainloop:
	docker run -d -p 127.0.0.1:33100:80 dockermail/rainloop:1.6.9

run-mailpile:
	docker run -d -p 127.0.0.1:33411:33411 dockermail/mailpile:latest

run-owncloud:
	docker run -d  -e VIRTUAL_HOST=owncloud.n00dl3.ovh -v /srv/owncloud:/var/www/owncloud/data -e DB_NAME=owncloud -e DB_USER=owncloud -e DB_PASSWORD=password --link mysql:mysql --name owncloud dockermail/owncloud:8.0.2

run-all: run-dovecot run-rainloop run-owncloud
