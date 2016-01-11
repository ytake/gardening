#!/usr/bin/env bash

mkdir /etc/httpd/ssl 2>/dev/null

PATH_SSL="/etc/httpd/ssl"
PATH_KEY="${PATH_SSL}/${1}.key"
PATH_CSR="${PATH_SSL}/${1}.csr"
PATH_CRT="${PATH_SSL}/${1}.crt"

if [ ! -f $PATH_KEY ] || [ ! -f $PATH_CSR ] || [ ! -f $PATH_CRT ]
then
  openssl genrsa -out "$PATH_KEY" 2048 2>/dev/null
  openssl req -new -key "$PATH_KEY" -out "$PATH_CSR" -subj "/CN=$1/O=Vagrant/C=UK" 2>/dev/null
  openssl x509 -req -days 365 -in "$PATH_CSR" -signkey "$PATH_KEY" -out "$PATH_CRT" 2>/dev/null
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
        SetHandler "proxy:unix:/var/run/php7-fpm.sock\|fcgi://localhost"
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
        SetHandler "proxy:unix:/var/run/php7-fpm.sock\|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
"

echo "$block" > "/etc/httpd/conf.d/$1.conf"

HH_CONFIG=$2/.hhconfig
if [ -f "$HH_CONFIG" ]; then
    rm -rf $2/.hhconfig
fi

/bin/systemctl restart php-fpm
/bin/systemctl restart httpd
