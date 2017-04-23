#
# @file
# Docker file.
#
# Copyright © 2015, Ahmed Kamal. (https://github.com/ahmedkamals)
#
# This file is part of Ahmed Kamal's Docker configurations.
# ® Redistributions of files must retain the above copyright notice.
#
# @copyright     Ahmed Kamal (https://github.com/ahmedkamals)
# @link          https://github.com/ahmedkamals/dev-environment
# @package       AK
# @subpackage    Docker
# @version       1.0
# @since         2015-01-25 Happy day :)
# @license
# @author        Ahmed Kamal <me.ahmed.kamal@gmail.com>
# @modified      2015-01-25
#
FROM ubuntu:14.04
MAINTAINER Ahmed Kamal <me.ahmed.kamal@gmail.com>

# Install dependencies && Apache2:
RUN apt-get update -y && RUN apt-get install -y software-properties-common nano wget apache2 apache2-utils libapache2-mod-fastcgi cronolog httpie curl htop unrar-free xclip

# Enabling actions, fastcgi, rewrite, headers, expires, macro, proxy_http, and proxy_fcgi modules:
RUN a2enmod actions fastcgi rewrite headers expires macro proxy_http

# This will reduce the memory footprint of Apache, "negotiation" allows some languages negociation in the HTTP protocol between the browser and the server:
RUN a2dismod autoindex cgid negotiation

# Copying apache configurations:
RUN cp apache/conf-available/*.conf /etc/apache2/conf-available/ -R
RUN cp apache/sites-available/*.conf /etc/apache2/sites-available/ -R

# Enabling configurations
RUN a2enconf settings *-macro

# Configure apache:
RUN chown -R www-data:www-data /var/www

# ADD apache.conf /etc/apache2/sites-available/default
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2


CMD ["/usr/sbin/apache2", "-D",  "FOREGROUND"]

EXPOSE 80
