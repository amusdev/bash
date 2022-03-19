#!/bin/bash

if [ -z ${BASH_COMMON_DEFINE+x} ]; then
    if [ ! -f ../common.sh ]; then
        source <(curl -s https://amusdev.github.io/bash/common.sh)
    else
        source ../common.sh
    fi
fi

PHP_AVAILABLE_VERSIONS=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0")

function build_extension_string(){
    # support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
    local extensions=("fpm" "bcmath" "common" "curl" "json" "mysql" "mbstring" "xml" "zip" "gd" "soap" "ssh2" "tokenizer" "intl" "xsl" "mcrypt")

    local old_ifs=$IFS
    IFS=" "
    local prefix_extensions=( "${extensions[@]/#/$1}" )
    echo "${prefix_extensions[*]}"
    IFS=$old_ifs
}

# ------------------------------------------------------
# string[] PHP_AVAILABLE_VERSIONS=?
# require_php_version_from_cli(&string return)
# ------------------------------------------------------
function require_php_version_from_cli(){
    local version=""
    while read -p "PHP Version: " version < /dev/tty && [[ ! " ${PHP_AVAILABLE_VERSIONS[@]} " =~ " ${version} " ]];
    do
        echo -e "${ERROR_STYLE}The PHP version($version) you typed is not supported, please enter another one.\e[0m"
        echo "Supported versions are ${PHP_AVAILABLE_VERSIONS[*]}"
    done
    eval "$1=$version"
}

# ------------------------------------------------------
# string[] PHP_AVAILABLE_VERSIONS=?
# install_php_check_available(string version)
# ------------------------------------------------------
function install_php_check_available(){
    local version=$1
    if [[ ! " ${PHP_AVAILABLE_VERSIONS[@]} " =~ " ${version} " ]]; then
        echo -e "${ERROR_STYLE}The PHP version($version) you typed is not supported.\e[0m"
        exit 1
    fi
}

# ------------------------------------------------------
# string[] PHP_AVAILABLE_VERSIONS=?
# install_php(string version)
# ------------------------------------------------------
function install_php(){
    # capture_linux_version from common.sh
    local os=$(capture_linux_version)
    # capture_centos_major_verison from common.sh
    local centos_major=$(capture_centos_major_verison)
    local version=$1

    install_php_check_available $version

    if [[ $os == "Ubuntu" ]];
    then
        apt -y install software-properties-common
        add-apt-repository -y ppa:ondrej/php
        apt update
        eval "apt -y install openssl php${version} $(build_extension_string "php${version}-")"
        #update-alternatives --set php /usr/bin/php${version}
    elif [[ $os == "Debian" ]];
    then
        apt -y install lsb-release apt-transport-https ca-certificates
        wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
        echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
        apt update
        eval "apt -y install openssl php${version} $(build_extension_string "php${version}-")"
        #update-alternatives --set php /usr/bin/php${version}
    elif [[ $os == "CentOS" ]];
    then
        yum -y install epel-release
        yum -y install https://rpms.remirepo.net/enterprise/remi-release-$centos_major.rpm
        yum makecache
        eval "yum -y install openssl php${version/\./} $(build_extension_string "php${version/\./}-php-")"
    fi
}

function print_php_finish(){
    # capture_linux_version from common.sh
    local os=$(capture_linux_version)
    local version=$1
    echo "PHP >>"
    echo -e "${INFO_STYLE}The system finished installing PHP with version: ${VERSION_STYLE}$version\e[0m"
    if [[ $os == "CentOS" ]]; then
        version=${version/\./}
    fi
    echo -e "Tips: you could run ${COMMEND_STYLE}php$version -v\e[0m to view installed PHP."
}