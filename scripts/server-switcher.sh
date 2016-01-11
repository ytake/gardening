#!/usr/bin/env bash
# for httpd

PROCESS=$1

HTTPD_STATUS=`systemctl is-enabled httpd`
NGINX_STATUS=`systemctl is-enabled nginx`

if [ $PROCESS = 'httpd' ]; then
    if [ $NGINX_STATUS = 'enabled' ]; then
    systemctl disable nginx;
    systemctl stop nginx;
    fi

    systemctl enable httpd;
    systemctl restart httpd;
else
    if [ $HTTPD_STATUS = 'enabled' ]; then
    systemctl disable httpd;
    systemctl stop httpd;
    fi

    systemctl enable nginx;
    systemctl restart nginx;
fi
