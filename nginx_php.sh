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
import_from_local_or_remote modules/nginx.sh

# check_env from common.sh
check_env

while getopts "p:" args;
do
    case "${args}" in
        p)
            PHP_VERSION=${OPTARG}
            ;;
        *)
            ;;
    esac
done

if [ -z "$PHP_VERSION" ]; then
    require_php_version_from_cli PHP_VERSION
fi

install_php_check_available $PHP_VERSION

install_nginx
install_php $PHP_VERSION

tput reset
print_nginx_finish
print_php_finish $PHP_VERSION
