# Apache & PHP 5.5, without MySQL. No Supervisor needed.
#
# VERSION: 1.9
# DOCKER-VERSION: 1.0.0
# AUTHOR: Jared Markell <jaredm4@gmail.com>
# TO_RUN: docker run -d -p 80:80 jaredm4/apache-php55
# CHANGELOG:
# 1.9 Updated to Ubuntu 14.04. Added php5-redis. Removed mcrypt hack.
# 1.8 Upped upload max size to 10M.
# 1.7 Fix prod.ini loading and enable mcrypt by default
# 1.6 Added Subversion back in due to Composer needs.
# 1.5 Added php5-json.
# 1.4 prod.ini enhancements.
# 1.3 Added php5-cli.
# 1.2 Volume'd the /var/log directory entirely.
# 1.1 Re-ordered some elements, re-built on Docker 0.8.1.
# 1.0 Based loosely on 1.3 of jaredm4/apache-php54, without mongo, sqlite or subversion.

FROM ubuntu:14.04

MAINTAINER Jared Markell, jaredm4@gmail.com

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Utilities and Apache, PHP
RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get -y install git subversion curl apache2 php5 php5-cli libapache2-mod-php5 php5-json php5-mysql php-apc php5-gd php5-curl php5-redis php5-memcached php5-mcrypt &&\
    apt-get clean

# PHP prod config
ADD files/prod.ini /etc/php5/conf.d/prod.ini
RUN cd /etc/php5/cli/conf.d && ln -s ../../conf.d/prod.ini prod.ini &&\
    cd /etc/php5/apache2/conf.d && ln -s ../../conf.d/prod.ini prod.ini

# Ensure PHP log file exists and is writable
RUN touch /var/log/php_errors.log && chmod a+w /var/log/php_errors.log

# Turn on some crucial apache mods
RUN a2enmod rewrite headers

# Our start-up script
ADD files/start.sh /start.sh
RUN chmod a+x /start.sh

VOLUME ["/var/log"]

ENTRYPOINT ["/start.sh"]
EXPOSE 80
