#!/bin/bash

source <(curl -s https://amusdev.github.io/bash/common.sh)
source <(curl -s https://amusdev.github.io/bash/php.sh)
source <(curl -s https://amusdev.github.io/bash/mysql.sh)
source <(curl -s https://amusdev.github.io/bash/nginx.sh)

# check_env from common.sh
check_env
if [ $? -eq 1 ]; then
    echo "This bash required root permission."
    exit 1
elif [ $? -eq 2 ] | [ $? -eq 3 ]; then
  echo "Not supported OS, Please refer to minimum support OS to learn more."
fi

# capture_linux_version from common.sh
LINUX_OS=$(capture_linux_version)
# capture_ubuntu_major_version from common.sh
UBUNTU_MAJOR_VERSION=$(capture_ubuntu_major_version)
# capture_centos_major_verison from common.sh
CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)

while getopts "m:p:t:" args;
do
    case "${args}" in
        p)
            PHP_VERSION=${OPTARG}
            ;;
        m)
            MYSQL_VERSION=${OPTARG}
            ;;
        t)
            MYSQL_PASSWORD=${OPTARG}
            ;;
        *)
            ;;
    esac
done
PHP_VERSION=${PHP_VERSION:-"7.3"}
MYSQL_VERSION=${MYSQL_VERSION:-"5.7"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"P@ssw0rd"}

install_nginx
install_mysql $MYSQL_VERSION $MYSQL_PASSWORD
install_php $PHP_VERSION

tput reset
print_nginx_finish
print_php_finish
