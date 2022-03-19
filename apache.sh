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
import_from_local_or_remote modules/apache.sh

install_apache
tput reset
print_apache_finish