all: mail-base dovecot rainloop owncloud

.PHONY: mail-base dovecot rainloop owncloud run-dovecot run-rainloop run-owncloud
postfixadmin
	cd postfixadmin; docker build -t postfixadmin .

dovecot:
	cd dovecot; docker build -t dovecot:2.1.7 .

rainloop:
	cd rainloop; docker build -t rainloop:1.6.9 .

mailpile:
	cd mailpile; docker build -t mailpile:latest .

owncloud:
	cd owncloud; docker build -t owncloud:8.0.2 .

run-dovecot:
	docker run -v /path/to/certs:/srv/ssl -e DB_NAME=postfixadmin -e DB_USER=postfixadmin -e DB_PASSWD=password -d -p 25:25 -p 587:587 -p 143:143 -p 993:993 -v /srv/vmail:/srv/vmail dovecot:2.1.7

run-rainloop:
	docker run -d -p 127.0.0.1:33100:80 rainloop:1.6.9

run-mailpile:
	docker run -d -p 127.0.0.1:33411:33411 mailpile:latest

run-owncloud:
	docker run -d -p 127.0.0.1:33200:80 -v /srv/owncloud:/var/www/owncloud/data owncloud:8.0.2

run-all: run-dovecot run-rainloop run-owncloud
