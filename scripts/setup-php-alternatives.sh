#!/usr/bin/env bash

PHP=$1

if [ $PHP = "7.0" ];
then
    sudo update-alternatives --set php /opt/remi/php70/root/usr/bin/php
elif [ $PHP = "7.1" ];
then
    sudo update-alternatives --set php /opt/remi/php71/root/usr/bin/php
else
    sudo update-alternatives --set php /opt/remi/php72/root/usr/bin/php
fi

php -v

