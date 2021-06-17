# Bash
This repo aims to provide common bash script for using in production.  

# Support Environments
Ubuntu 16.04 <= v <= 20.04  
Debian 8 <= v <= 10  
CentOS 6 <= v <= 8

## Usage
### Apache 2
execute this command will auto install Apache2 latest vesion
```bash
curl -s https://amusdev.github.io/bash/apache.sh | sudo bash
```
### Nginx
execute this command will auto install Nginx latest vesion
```bash
curl -s https://amusdev.github.io/bash/nginx.sh | sudo bash
```
### PHP
execute this command will auto install custom PHP version  
available version: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0
```bash
curl -s https://amusdev.github.io/bash/php.sh | sudo bash -s -- -v 7.3
```
### MySQL
execute this command will auto install custom MySQL version  
available version: 5.7, 8.0
```bash
curl -s https://amusdev.github.io/bash/mysql.sh | sudo bash -s -- -v 5.7 -p "P@ssw0rd"
```
### Apache + PHP
execute this command will auto install Apache2 latest vesion and custom PHP version  
available version: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0
```bash
curl -s https://amusdev.github.io/bash/apache_php.sh | sudo bash -s -- -p 7.3
```
### Nginx + PHP
execute this command will auto install Nginx latest vesion and custom PHP version  
available version: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0
```bash
curl -s https://amusdev.github.io/bash/nginx_php.sh | sudo bash -s -- -p 7.3
```
### Nginx + PHP + MySQL
execute this command will auto install Nginx latest vesion and custom PHP version and custom MySQL version
```bash
curl -s https://amusdev.github.io/bash/nginx_php_mysql.sh | sudo bash -s -- -p 7.3 -m 5.7 -t "P@ssw0rd"
```
