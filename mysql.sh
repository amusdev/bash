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
import_from_local_or_remote modules/mysql.sh

while getopts "v:p:" args;
do
    case "${args}" in
        v)
            MYSQL_VERSION=${OPTARG}
            ;;
        p)
            MYSQL_PASSWORD=${OPTARG}
            ;;
        *)
            ;;
    esac
done

if [ -z "$MYSQL_VERSION" ]; then
    require_mysql_version_from_cli MYSQL_VERSION
fi
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"P@ssw0rd"}

install_mysql_check_available $MYSQL_VERSION

install_mysql $MYSQL_VERSION $MYSQL_PASSWORD
print_mysql_finish $MYSQL_VERSION $MYSQL_PASSWORD