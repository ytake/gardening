#!/usr/bin/env bash

sudo sed -i '/# Set Gardening Environment Variable/,+1d' /home/vagrant/.profile
sed -i '/env\[.*/,+1d' /etc/php-fpm.d/www.conf
