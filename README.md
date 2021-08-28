# Bash
This repository aims to provide common bash script for using in production.  

## Support Environments
Ubuntu 16.04 <= OS <= 20.04  
Debian 8 <= OS <= 10  
CentOS 6 <= OS <= 8

## Usage
### Apache 2
Execute this command will auto install Apache2 latest vesion
```bash
curl -s https://amusdev.github.io/bash/apache.sh | sudo bash
```
### Nginx
Execute this command will auto install Nginx latest vesion
```bash
curl -s https://amusdev.github.io/bash/nginx.sh | sudo bash
```
### PHP
Execute this command will auto install custom PHP version  
Available version: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0
```bash
curl -s https://amusdev.github.io/bash/php.sh | sudo bash -s -- -v 7.3
```
#### Alternative
```bash
export PHP_VERSION=7.3
curl -s https://amusdev.github.io/bash/php.sh | sudo bash
```
### Node.js
Execute this command will auto install custom Node.js version and npm version  
Available version: 10, 11, 12, 13, 14, 15, 16  
n: NPM version, available: 5, 6, 7
```bash
curl -s https://amusdev.github.io/bash/nodejs.sh | sudo bash -s -- -v 16 -n 7
```
#### Alternative
```bash
export NODEJS_VERSION=14
export NPM_VERSION=7
curl -s https://amusdev.github.io/bash/php.sh | sudo bash
```
### MySQL
Execute this command will auto install custom MySQL version  
Available version: 5.7, 8.0
```bash
curl -s https://amusdev.github.io/bash/mysql.sh | sudo bash -s -- -v 5.7 -p "P@ssw0rd"
```
#### Alternative
```bash
export MYSQL_VERSION=5.7
export MYSQL_PASSWORD=P@ssw0rd
curl -s https://amusdev.github.io/bash/php.sh | sudo bash
```
### Apache + PHP
Execute this command will auto install Apache2 latest vesion and custom PHP version  
Available version: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0
```bash
curl -s https://amusdev.github.io/bash/apache_php.sh | sudo bash -s -- -p 7.3
```
#### Alternative
```bash
export PHP_VERSION=7.3
curl -s https://amusdev.github.io/bash/apache_php.sh | sudo bash
```
### Nginx + PHP
Execute this command will auto install Nginx latest vesion and custom PHP version  
Available version: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0
```bash
curl -s https://amusdev.github.io/bash/nginx_php.sh | sudo bash -s -- -p 7.3
```
#### Alternative
```bash
export PHP_VERSION=7.3
curl -s https://amusdev.github.io/bash/nginx_php.sh | sudo bash
```
### Nginx + PHP + MySQL
Execute this command will auto install Nginx latest vesion and custom PHP Version and custom MySQL version  
PHP available version: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0  
MySQL available version: 5.7, 8.0  
t = MySQL Password
```bash
curl -s https://amusdev.github.io/bash/nginx_php_mysql.sh | sudo bash -s -- -p 7.3 -m 5.7 -t "P@ssw0rd"
```
#### Alternative
```bash
export PHP_VERSION=7.3
export MYSQL_VERSION=5.7
export MYSQL_PASSWORD=P@ssw0rd
curl -s https://amusdev.github.io/bash/nginx_php_mysql.sh | sudo bash
```
