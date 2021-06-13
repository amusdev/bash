#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This bash required root permission."
    exit 1
fi

function build_extension_string(){
    old_ifs=$IFS
    IFS=" "
    PREFIX_EXTENDSIONS=( "${EXTENDSIONS[@]/#/$1}" )
    echo "${PREFIX_EXTENDSIONS[*]}"
    IFS=$old_ifs
}

function install_php(){
    AVAILABLE_VERSION=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0")

    while read -p "PHP Version: " VERSION < /dev/tty && [[ ! " ${AVAILABLE_VERSION[@]} " =~ " ${VERSION} " ]];
    do
        echo "Your inputted version($VERSION) is not supported, please enter another one."
        echo "Support versions are (${AVAILABLE_VERSION[*]})"
    done

    # support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
    EXTENDSIONS=("fpm" "bcmath" "common" "curl" "json" "mysql" "mbstring" "xml" "zip" "gd" "soap" "ssh2" "tokenizer" "intl" "xsl" "mcrypt")

    if [[ $LINUX_OS == "Ubuntu" ]];
    then
        apt -y install software-properties-common
        add-apt-repository -y ppa:ondrej/php
        apt update
        eval "apt -y install openssl php${VERSION} $(build_extension_string "php${VERSION}-")"
        #update-alternatives --set php /usr/bin/php${VERSION}
    elif [[ $LINUX_OS == "Debian" ]];
    then
        apt -y install lsb-release apt-transport-https ca-certificates
        wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
        echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
        apt update
        eval "apt -y install openssl php${VERSION} $(build_extension_string "php${VERSION}-")"
        #update-alternatives --set php /usr/bin/php${VERSION}
    elif [[ $LINUX_OS == "CentOS" ]];
    then
        yum -y install epel-release
        yum -y install https://rpms.remirepo.net/enterprise/remi-release-$CENTOS_MAJOR_VERSION.rpm
        yum makecache
        eval "yum -y install openssl php${VERSION/\./} $(build_extension_string "php${VERSION/\./}-php-")"
    fi
}

function print_php_finish(){
    echo "Successful install PHP with version: $VERSION"
    if [[ $LINUX_OS == "CentOS" ]]; then
        VERSION=${VERSION/\./}
    fi
    echo "Tips: you could run \`php$VERSION -v\` to view installed php."
}

([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] || 
 [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
    printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] || 
 [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)) && IS_SOURCED_BASH=1 || IS_SOURCED_BASH=0
 
 if [ $IS_SOURCED_BASH -eq 0 ]; then
    install_php
    tput reset
    print_php_finish
 fi
