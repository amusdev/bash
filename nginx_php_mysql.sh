#!/bin/bash

if [ -z ${BASH_COMMON_DEFINE+x} ]; then
    if [ ! -f ./common.sh ]; then
        source <(curl -s https://amusdev.github.io/bash/common.sh)
    else
        source ./common.sh
    fi
fi

# common.sh
import_from_local_or_remote modules/php.sh
# common.sh
import_from_local_or_remote modules/mysql.sh
# common.sh
import_from_local_or_remote modules/nginx.sh

# check_env from common.sh
check_env

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

if [ -z "$PHP_VERSION" ]; then
    require_php_version_from_cli PHP_VERSION
fi
if [ -z "$MYSQL_VERSION" ]; then
    require_mysql_version_from_cli MYSQL_VERSION
fi
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"P@ssw0rd"}

install_php_check_available $PHP_VERSION
install_mysql_check_available $MYSQL_VERSION

install_nginx
install_mysql $MYSQL_VERSION $MYSQL_PASSWORD
install_php $PHP_VERSION

tput reset
print_nginx_finish
print_php_finish $PHP_VERSION
print_mysql_finish $MYSQL_VERSION $MYSQL_PASSWORD