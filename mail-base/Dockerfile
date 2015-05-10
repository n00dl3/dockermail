FROM phusion/baseimage:0.9.16

ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales

RUN apt-get update

RUN apt-get -y -q autoclean
RUN apt-get -y -q autoremove
RUN apt-get clean

ADD ./domains /domains
ADD ./aliases /aliases
ADD ./passwords /passwords
