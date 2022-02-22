# Bash
This repository aims to provide common bash script for using in production.  

## Support Environments
Ubuntu 16.04 <= OS <= 20.04  
Debian 8 <= OS <= 10  
CentOS 6 <= OS <= 8

## Usage
### Apache 2
Install `Apache2` latest vesion
```bash
curl -s https://amusdev.github.io/bash/apache.sh | sudo bash
```
### Nginx
Install `Nginx` latest vesion
```bash
curl -s https://amusdev.github.io/bash/nginx.sh | sudo bash
```
### PHP
Install `PHP` version as `5.6` | `7.0` | `7.1` | `7.2` | `7.3` | `7.4` | `8.0`
```bash
curl -s https://amusdev.github.io/bash/php.sh | sudo bash -s -- -v {{php_version}}
```
#### Alternative
```bash
export PHP_VERSION=7.3
curl -s https://amusdev.github.io/bash/php.sh | sudo bash
```
### Node.js
Install `Node.js` version as `10.x` | `11.x` | `12.x` | `13.x` | `14.x` | `15.x` | `16.x`  
Install `npm` version as `5.x` | `6.x` | `7.x`  
```bash
curl -s https://amusdev.github.io/bash/nodejs.sh | sudo bash -s -- -v {{node_version}} -n {{npm_version}}
```
#### Alternative
```bash
export NODEJS_VERSION=14
export NPM_VERSION=7
curl -s https://amusdev.github.io/bash/php.sh | sudo bash
```
### MySQL
Install `MySQL` version as `5.7` | `8.0`
```bash
curl -s https://amusdev.github.io/bash/mysql.sh | sudo bash -s -- -v {{MySQL_version}} -p {{MySQL_root_password}}
```
#### Alternative
```bash
export MYSQL_VERSION=5.7
export MYSQL_PASSWORD=P@ssw0rd
curl -s https://amusdev.github.io/bash/php.sh | sudo bash
```
### Apache + PHP
Install `Apache2` latest version  
Install `PHP` version as `5.6` | `7.0` | `7.1` | `7.2` | `7.3` | `7.4` | `8.0`
```bash
curl -s https://amusdev.github.io/bash/apache_php.sh | sudo bash -s -- -p {{php_version}}
```
#### Alternative
```bash
export PHP_VERSION=7.3
curl -s https://amusdev.github.io/bash/apache_php.sh | sudo bash
```
### Nginx + PHP
Install `Nginx` latest vesion  
Install `PHP` version as `5.6` | `7.0` | `7.1` | `7.2` | `7.3` | `7.4` | `8.0`
```bash
curl -s https://amusdev.github.io/bash/nginx_php.sh | sudo bash -s -- -p {{php_version}}
```
#### Alternative
```bash
export PHP_VERSION=7.3
curl -s https://amusdev.github.io/bash/nginx_php.sh | sudo bash
```
### Nginx + PHP + MySQL
Install `Nginx` latest vesion  
Install `PHP` version as `5.6` | `7.0` | `7.1` | `7.2` | `7.3` | `7.4` | `8.0`  
Install `MySQL` version as `5.7` | `8.0`
```bash
curl -s https://amusdev.github.io/bash/nginx_php_mysql.sh | sudo bash -s -- -p {{php_version}} -m {{MySQL_version}} -t {{MySQL_root_password}}
```
#### Alternative
```bash
export PHP_VERSION=7.3
export MYSQL_VERSION=5.7
export MYSQL_PASSWORD=P@ssw0rd
curl -s https://amusdev.github.io/bash/nginx_php_mysql.sh | sudo bash
```
