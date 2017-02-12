#!/usr/bin/env bash

DB=$1;

mysql -u gardening -p00:secreT,@ -e "CREATE DATABASE IF NOT EXISTS \`$DB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci";
