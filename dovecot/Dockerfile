FROM ubuntu:14.04
ENV DEBIAN_FRONTEND=noninteractive
#from mail-base
# prerequisites
RUN apt-get update
# Install postfix as MTA
RUN apt-get install -y postfix dovecot-imapd dovecot-mysql dovecot-core amavisd-new clamav clamav-daemon spamassassin postfix-mysql postgrey
RUN freshclam
#create dir and volume for ssl certificates
RUN mkdir -p /srv/ssl
VOLUME /srv/ssl

# add user vmail who own all mail folders
RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d /srv/vmail -m
RUN chown -R vmail:vmail /srv/vmail
RUN chmod u+w /srv/vmail
RUN echo "mail.docker.container" > /etc/mailname
ADD amavis /root/amavis
#dovecot configuration
ADD dovecot /root/dovecot
#postfix config
ADD postfix /root/postfix
# dovecot configuration
ADD ./start.sh /root/start_server.sh
RUN chmod +x /root/start_server.sh
# add verbose logging
#ADD ./internal/dovecot.logging /etc/dovecot/conf.d/10-logging.conf

# i'm not sure what expose actually does, so its mainly here for documentation
# smtp port for incoming mail
EXPOSE 25
# imap port
EXPOSE 143
# imaps port
EXPOSE 993
# smtp port for outgoing
EXPOSE 587

ENTRYPOINT /root/start_server.sh

# todo: enable port 587 for outgoing mail, separate ports 25 and 587
# http://www.synology-wiki.de/index.php/Zusaetzliche_Ports_fuer_Postfix
