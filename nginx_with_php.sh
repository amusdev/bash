#!/bin/bash

source <(curl -s https://amusdev.github.io/bash/common.sh)
source <(curl -s https://amusdev.github.io/bash/php.sh)
source <(curl -s https://amusdev.github.io/bash/nginx.sh)

# capture_linux_version from common.sh
LINUX_OS=$(capture_linux_version)
# capture_centos_major_verison from common.sh
CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)

if [[ $LINUX_OS == "Others" ]]; then
    echo "This bash only executable on Ubuntu, Debian, CentOS."
    exit 1
fi

if [[ $LINUX_OS == "CentOS" ]]; then
    if [ $CENTOS_MAJOR_VERSION -lt 5 ] || [ $CENTOS_MAJOR_VERSION -gt 8 ]; then
        echo "This bash only executable on CentOS 5 - 8."
        exit 1
    fi
fi

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This bash required root permission."
    exit 1
fi

install_nginx
if [ $? -ne 0 ]; then
    echo "Sorry, we have an error during installing nginx."
    exit 1
fi
install_php
if [ $? -ne 0 ]; then
    echo "Sorry, we have an error during installing php."
    exit 1
fi
print_finish
