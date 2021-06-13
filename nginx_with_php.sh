#!/bin/bash

source <(curl -s https://amusdev.github.io/bash/common.sh)
source <(curl -s https://amusdev.github.io/bash/php.sh)
source <(curl -s https://amusdev.github.io/bash/nginx.sh)

# check_env from common.sh
check_env
if [ $? -eq 1 ]; then
    echo "This bash required root permission."
    exit 1
elif [ $? -eq 2 ]; then
    echo "This bash only executable on Ubuntu, Debian, CentOS."
    exit 1
elif [ $? -eq 3 ]; then
    echo "This bash only executable on CentOS 5 - 8."
    exit 1
fi

# capture_linux_version from common.sh
LINUX_OS=$(capture_linux_version)
# capture_centos_major_verison from common.sh
CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)

install_nginx
install_php $LINUX_OS $CENTOS_MAJOR_VERSION

tput reset
print_nginx_finish
print_php_finish
