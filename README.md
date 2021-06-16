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
```bash
curl -s https://amusdev.github.io/bash/php.sh | sudo bash -s -- -v 7.3
```
### MySQL
execute this command will auto install custom MySQL version
```bash
curl -s https://amusdev.github.io/bash/mysql.sh | sudo bash
```
### Apache + PHP
execute this command will auto install Apache2 latest vesion and custom PHP version
```bash
curl -s https://amusdev.github.io/bash/apache_php.sh | sudo bash
```
### Nginx + PHP
execute this command will auto install Nginx latest vesion and custom PHP version
```bash
curl -s https://amusdev.github.io/bash/nginx_php.sh | sudo bash
```
### Nginx + PHP + MySQL
execute this command will auto install Nginx latest vesion and custom PHP version and custom MySQL version
```bash
curl -s https://amusdev.github.io/bash/nginx_php_mysql.sh | sudo bash
```
