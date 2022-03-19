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
import_from_local_or_remote modules/nodejs.sh

while getopts "v:n:" args;
do
    case "${args}" in
        v)
            NODEJS_VERSION=${OPTARG}
            ;;
        n)
            NPM_VERSION=${OPTARG}
            ;;
        *)
            ;;
    esac
done

if [ -z "$NODEJS_VERSION" ]; then
    require_nodejs_version_from_cli NODEJS_VERSION
fi
if [ -z "$NPM_VERSION" ]; then
    require_npm_version_from_cli NPM_VERSION
fi

install_nodejs_check_available $NODEJS_VERSION $NPM_VERSION

install_nodejs $NODEJS_VERSION $NPM_VERSION
tput reset
print_nodejs_finish $NODEJS_VERSION $NPM_VERSION