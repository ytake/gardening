#!/usr/bin/env bash

PHP=$5
PHP_SOCKET="php72-fpm.sock"

if [ $PHP = '7.0' ];
then
    PHP_SOCKET="php70-fpm.sock"
elif [ $PHP = '7.1' ];
then
    PHP_SOCKET="php71-fpm.sock"
else
    PHP_SOCKET="php72-fpm.sock"
fi

block="
<VirtualHost *:80>
    DocumentRoot \"$2\"
    ServerName $1
    ErrorLog "/var/log/httpd/$1-error_log"
    DirectoryIndex index.php index.html
    <Directory $2>
        AllowOverride All
        Require all granted
    </Directory>
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/var/run/$PHP_SOCKET\|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
<VirtualHost *:443>
    DocumentRoot \"$2\"
    ServerName $1
    ErrorLog "/var/log/httpd/$1-error_log"
    DirectoryIndex index.php index.html

    SSLEngine on
    SSLCertificateFile $PATH_CRT
    SSLCertificateKeyFile $PATH_KEY

    <Directory $2>
        AllowOverride All
        Require all granted
    </Directory>
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/var/run/PHP_SOCKET\|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
"

echo "$block" > "/etc/httpd/conf.d/$1.conf"

/bin/systemctl restart httpd
