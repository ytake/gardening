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

block="server {
    listen ${3:-80};
    listen ${4:-443} ssl;
    server_name $1;
    root \"$2\";

    index index.html index.htm index.php app_dev.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /app_dev.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-ssl-error.log error;

    sendfile off;

    client_max_body_size 100m;

    # DEV
    location ~ ^/(app_dev|app_test|config)\.php(/|\$) {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/var/run/$PHP_SOCKET;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
    }

    # PROD
    location ~ ^/app\.php(/|$) {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/$PHP_SOCKET;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        internal;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/$1.crt;
    ssl_certificate_key /etc/nginx/ssl/$1.key;
}
"

echo "$block" > "/etc/nginx/conf.d/$1.conf"

sed -i "s/user nginx;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/user  nginx;/user vagrant;/" /etc/nginx/nginx.conf
/bin/systemctl restart nginx
