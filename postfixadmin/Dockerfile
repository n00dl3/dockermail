FROM dockermail/web-base
RUN apt-get update && apt-get install -y php5-imap mysql-client
WORKDIR /tmp
RUN wget http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.92/postfixadmin-2.92.tar.gz
RUN tar -xvf postfixadmin-2.92.tar.gz
RUN rm -rf /var/www
RUN mv postfixadmin-2.92 /var/www
RUN chown -R root:www-data /var/www
ADD postfixadmin.sh /etc/service/postfixadmin/run
ADD config.inc.php /var/www/config.inc.php
ADD database.sql /root/database.sql
RUN chmod +x /etc/service/postfixadmin/run
EXPOSE 80
