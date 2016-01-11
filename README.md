# Gardening

pre-packaged Vagrant box that provides you a wonderful development environment  
without requiring you to install PHP(7.*), HHVM(3.9), a web server(Nginx or Apache),  
and any other server software on your local machine.

(supported for virtualbox only)

## Included Software
 - CentOS 7
 - Git
 - PHP 7.0(remi repository)
 - HHVM(3.9)
 - Apache(2.4.6)
 - Nginx(1.8)
 - MySQL(5.6)
 - Sqlite3
 - PostgreSQL(9.4)
 - Composer
 - Node.js (With Grunt, and Gulp)
 - Redis
 - Memcached
 - Elasticsearch
 - MongoDB
 - Java(1.8)
 - fluentd
 - Couchbase

## Install Gardening Box

### case 1, your "home" directory
```bash
$ cd ~
$ git clone https://github.com/ytake/gardening.git gardening
```

setup.sh(Windows .bat) command from the gardening directory to create the vagrant.yaml configuration file.(~/.gardening hidden directory)

```bash
$ bash setup.sh
```

### case2, Per Project Installation

To install gardening directly into your project, require it using Composer:

```bash
$ composer require ytake/gardening --dev
```

## Configuration

### Choose Web Server
default Nginx

```yaml
web_server: nginx
```

Apache can be selected if necessary

```yaml
web_server: httpd
```

### Configuring Shared Folders

```yaml
folders:
    - map: /path/to/yourProject
      to: /home/vagrant/yourProjectName
```

many shared folders:
```yaml
folders:
    - map: /path/to/yourProject
      to: /home/vagrant/yourProjectName
    - map: /path/to/yourSecondfProject
      to: /home/vagrant/yourSecondProjectName
```

### Configuring Sites
```yaml
sites:
    - map: gardening.app
      to: /home/vagrant/yourProject/public
```

many sites:
```yaml
sites:
    - map: gardening.app
      to: /home/vagrant/yourProject/public
    - map: gardening.second.app
      to: /home/vagrant/yourSecondProject/public
```

use HHVM by setting the hhvm option to true:
```yaml
sites:
    - map: gardening.app
      to: /home/vagrant/yourProject/public
      hhvm: true
```

### Optional

use fluentd by setting the fluentd option to true:

```yaml
fluentd: true
```

use MongoDB by setting the mongodb option to true:

```yaml
mongodb: true
```

use Elasticsearch by setting the elasticsearch option to true:

```yaml
elasticsearch: true
```

### Ports

By default, the following ports are forwarded to your gardening environment:

 - SSH: 2222 → Forwards To 22
 - HTTP: 8000 → Forwards To 80
 - HTTPS: 44300 → Forwards To 443
 - MySQL: 33060 → Forwards To 3306
 - Postgres: 54320 → Forwards To 5432
 - MongoDB: 47017 → Forwards To 27017

Forwarding Additional Ports:
```yaml
ports:
    - send: 7777
      to: 777
```
