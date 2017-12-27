#!/usr/bin/env bash

sudo sed -i '/# Set Gardening Environment Variable/,+1d' /home/vagrant/.profile
sed -i '/env\[.*/,+1d' /etc/opt/remi/php70/php-fpm.d/www.conf
sed -i '/env\[.*/,+1d' /etc/opt/remi/php71/php-fpm.d/www.conf
sed -i '/env\[.*/,+1d' /etc/opt/remi/php72/php-fpm.d/www.conf

