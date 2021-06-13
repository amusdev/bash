#!/bin/bash

function install_mysql(){
    LINUX_OS=$1
    
    AVAILABLE_VERSION=("5.7" "8.0")

    while read -p "MySQL Version: " VERSION < /dev/tty && [[ ! " ${AVAILABLE_VERSION[@]} " =~ " ${VERSION} " ]];
    do
        echo "Your inputted version($VERSION) is not supported, please enter another one."
        echo "Support versions are (${AVAILABLE_VERSION[*]})"
    done
    
    if ! hash mysqld 2>/dev/null; then
        if [[ $LINUX_OS == "Ubuntu" ]] || [[ $LINUX_OS == "Debian" ]]; then
            curl -sL https://dev.mysql.com/get/mysql-apt-config_0.8.17-1_all.deb -o ./mysql_config.deb
            echo "mysql-apt-config mysql-apt-config/select-server select mysql-${VERSION}" | debconf-set-selections
            DEBIAN_FRONTEND=noninteractive dpkg -i ./mysql_config.deb
            apt update
            DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
        elif [[ $LINUX_OS == "CentOS" ]]; then
            if [[ $VERSION == "8.0" ]]; then
                yum -y insall https://repo.mysql.com/mysql80-community-release-el8-1.noarch.rpm
            elif [[ $VERISON == "5.7" ]]; then
                yum -y insall https://repo.mysql.com/mysql57-community-release-el7-9.noarch.rpm
            fi
            yum -y install mysql-community-server
        fi
    fi
}

([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] || 
 [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
    printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] || 
 [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)) && IS_SOURCED_BASH=1 || IS_SOURCED_BASH=0
 
 if [ $IS_SOURCED_BASH -eq 0 ]; then
    source <(curl -s https://amusdev.github.io/bash/common.sh)

    # check_env from common.sh
    check_env
    if [ $? -eq 1 ]; then
        echo "This bash required root permission."
        exit 1
    fi

    # capture_linux_version from common.sh
    LINUX_OS=$(capture_linux_version)
    # capture_centos_major_verison from common.sh
    CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)
 
    install_mysql $LINUX_OS
 fi
