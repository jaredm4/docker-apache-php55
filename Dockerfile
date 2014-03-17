# Apache & PHP 5.5, without MySQL. No Supervisor needed.
#
# VERSION: 1.7
# DOCKER-VERSION: 0.9.0
# AUTHOR: Jared Markell <jaredm4@gmail.com>
# TO_BUILD: docker build -rm -t jaredm4/apache-php55 .
# TO_RUN: docker run -d -p 80:80 jaredm4/apache-php55
# CHANGELOG:
# 1.7 Fix prod.ini loading and enable mcrypt by default
# 1.6 Added Subversion back in due to Composer needs.
# 1.5 Added php5-json.
# 1.4 prod.ini enhancements.
# 1.3 Added php5-cli.
# 1.2 Volume'd the /var/log directory entirely.
# 1.1 Re-ordered some elements, re-built on Docker 0.8.1.
# 1.0 Based loosely on 1.3 of jaredm4/apache-php54, without mongo, sqlite or subversion.

FROM ubuntu:13.10

MAINTAINER Jared Markell, jaredm4@gmail.com

# Setup locale and home - helps when using bash or Composer
RUN locale-gen en_US
ENV HOME /root

# Utilities and Apache, PHP
RUN apt-get update &&\
    apt-get upgrade -y &&\
    DEBIAN_FRONTEND=noninteractive apt-get -y install git subversion curl apache2 php5 php5-cli libapache2-mod-php5 php5-json php5-mysql php-apc php5-gd php5-curl php5-memcached php5-mcrypt &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# PHP prod config
ADD prod.ini /etc/php5/conf.d/prod.ini
RUN cd /etc/php5/cli/conf.d && ln -s ../../conf.d/prod.ini prod.ini &&\
    cd /etc/php5/apache2/conf.d && ln -s ../../conf.d/prod.ini prod.ini

# Fix broken mcrypt in this version of ubuntu
RUN cd /etc/php5 && mv conf.d/mcrypt.ini mods-available/mcrypt.ini &&\
    php5enmod mcrypt

# Ensure PHP log file exists and is writable
RUN touch /var/log/php_errors.log && chmod a+w /var/log/php_errors.log

# Our start-up script
ADD start.sh /start.sh
RUN chmod a+x /start.sh

# Turn on some crucial apache mods
RUN a2enmod rewrite headers filter

VOLUME ["/var/log"]

ENTRYPOINT ["/start.sh"]
EXPOSE 80
