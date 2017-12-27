#!/usr/bin/env bash

TIMEZONE=$1

timedatectl set-timezone $TIMEZONE
sudo timedatectl set-local-rtc 0
sudo timedatectl set-local-rtc true

sed -i "s|date.timezone.*|date.timezone = $TIMEZONE|g" /etc/opt/remi/php70/php.ini
sed -i "s|date.timezone.*|date.timezone = $TIMEZONE|g" /etc/opt/remi/php71/php.ini
sed -i "s|date.timezone.*|date.timezone = $TIMEZONE|g" /etc/opt/remi/php72/php.ini
