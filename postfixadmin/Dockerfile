FROM phusion/baseimage:0.9.16
RUN apt-get update && apt-get install -y apache2 php5 php5-imap php5-mysql wget mysql-client
WORKDIR /tmp
RUN wget http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.92/postfixadmin-2.92.tar.gz
RUN tar -xvf postfixadmin-2.92.tar.gz
RUN rm -rf /var/www/html
RUN mv postfixadmin-2.92 /var/www/html
RUN chown -R root:www-data /var/www/html
ADD postfixadmin.sh /etc/service/postfixadmin/run
ADD config.inc.php /var/www/html/config.inc.php
ADD database.sql /root/database.sql
RUN chmod +x /etc/service/postfixadmin/run
EXPOSE 80
