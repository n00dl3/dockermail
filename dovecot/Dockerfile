FROM phusion/baseimage:0.9.16
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

ADD amavis /root/amavis
#dovecot configuration
ADD dovecot /root/dovecot
#postfix config
ADD postfix /root/postfix
# dovecot configuration
ADD ./dovecot.sh /etc/service/dovecot/run
RUN chmod +x /etc/service/dovecot/run
ADD ./postfix.sh /etc/service/postfix/run
RUN chmod +x /etc/service/postfix/run
VOLUME /etc/postfix
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


# todo: enable port 587 for outgoing mail, separate ports 25 and 587
# http://www.synology-wiki.de/index.php/Zusaetzliche_Ports_fuer_Postfix
