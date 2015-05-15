all: mail-base dovecot rainloop owncloud

.PHONY: mail-base dovecot rainloop owncloud roundcube run-dovecot run-rainloop run-owncloud postfixadmin run-postfixadmin run-roundcube postfixadmin

postfixadmin:
	cd postfixadmin; docker build -t postfixadmin .

roundcube:
	cd roundcube; docker build -t n00dl3/roundcube .

dovecot:
	cd dovecot; docker build -t dovecot:2.1.7 .

rainloop:
	cd rainloop; docker build -t rainloop:1.6.9 .

mailpile:
	cd mailpile; docker build -t mailpile:latest .

owncloud:
	cd owncloud; docker build -t owncloud:8.0.2 .

postfixadmin:
	cd postfixadmin; docker build -t n00dl3/postfixadmin .

run-roundcube:
	docker run -e VIRTUAL_HOST=roundcube.n00dl3.ovh -e DB_NAME=roundcubemail -e DB_USER=roundcube -e DB_PASSWD=password --link mysql:mysql --link dovecot:dovecot -d --name roundcube n00dl3/roundcube

run-postfixadmin:
	docker run -e VIRTUAL_HOST=postfixadmin.n00dl3.ovh -e DB_NAME=postfixadmin -e DB_USER=postfix -e DB_PASSWD=password -e DOMAIN=n00dl3.ovh  --link dovecot:dovecot  --link mysql:mysql -d --name postfixadmin n00dl3/postfixadmin:latest

run-dovecot:
	docker run -e DB_NAME=postfixadmin -e DB_USER=postfixadmin -e DB_PASSWD=password -e DOMAIN=n00dl3.ovh -v /srv/certs:/srv/ssl -d -p 25:25 -p 587:587 -p 143:143 -p 993:993 -v /srv/vmail:/srv/vmail --name dovecot dovecot:2.1.7

run-rainloop:
	docker run -d -p 127.0.0.1:33100:80 rainloop:1.6.9

run-mailpile:
	docker run -d -p 127.0.0.1:33411:33411 mailpile:latest

run-owncloud:
	docker run -d -p 127.0.0.1:33200:80 -v /srv/owncloud:/var/www/owncloud/data owncloud:8.0.2

run-all: run-dovecot run-rainloop run-owncloud

