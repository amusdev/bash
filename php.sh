#!/bin/bash

if [ -z ${BASH_COMMON_DEFINE+x} ]; then
    if [ ! -f ./common.sh ]; then
        source <(curl -s https://amusdev.github.io/bash/common.sh)
    else
        source ./common.sh
    fi
fi

# check_env from common.sh
check_env

# common.sh
import_from_local_or_remote modules/php.sh

while getopts "v:" args;
do
    case "${args}" in
        v)
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

install_php $PHP_VERSION
tput reset
print_php_finish $PHP_VERSION