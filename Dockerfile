# Apache & PHP 5.5, without MySQL server. No Supervisor needed. Good for those who host MySQL on separate hosts.
#
# VERSION: 1.2.3
# DOCKER-VERSION: 1.2.0
# AUTHOR: Jared Markell <jaredm4@gmail.com>
# TO_RUN: docker run -d -p 80:80 jaredm4/apache-php55
# CHANGELOG:
# 1.2.3 Switch session path to /tmp.
# 1.2.2 Ensure /var/lib/php5 is writable (session default path)
# 1.2.1 Enabled PHP5 Mcrypt
# 1.2   Removed unnecessary apt-get upgrade. Added php5-mongo.
# 1.12  Fix php_errors.log permissions.
# 1.11  Disabled expose_php
# 1.10  No more declared VOLUME for /var/log. If you need to watch logs, use `-v /var/log` on runtime instead.
# 1.9   Updated to Ubuntu 14.04. Added php5-redis. Removed mcrypt hack.
# 1.8   Upped upload max size to 10M.
# 1.7   Fix prod.ini loading and enable mcrypt by default
# 1.6   Added Subversion back in due to Composer needs.
# 1.5   Added php5-json.
# 1.4   prod.ini enhancements.
# 1.3   Added php5-cli.
# 1.2   Volume'd the /var/log directory entirely.
# 1.1   Re-ordered some elements, re-built on Docker 0.8.1.
# 1.0   Based loosely on 1.3 of jaredm4/apache-php54, without mongo, sqlite or subversion.

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
    apt-get -y install git subversion curl apache2 php5 php5-cli libapache2-mod-php5 php5-mysql php-apc php5-gd php5-curl php5-memcached php5-mcrypt php5-mongo php5-sqlite php5-redis php5-json &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# Enable php5-mcrypt (not enabled by default)
RUN php5enmod mcrypt

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

EXPOSE 80
ENTRYPOINT ["/start.sh"]
