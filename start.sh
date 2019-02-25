#!/bin/sh
#########################################################################
# File Name: start.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2015/12/13
#########################################################################

Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/data/www

set -e
chown -R www.www $DATA_DIR


/usr/bin/supervisord -n -c /etc/supervisord.conf

