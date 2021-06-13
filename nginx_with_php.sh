#!/bin/bash

source ./common.sh

# capture_linux_version from common.sh
LINUX_OS=$(capture_linux_version)
# capture_centos_major_verison from common.sh
CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)

if [[ LINUX_OS == "Others" ]]; then
    echo "This bash only executable on Ubuntu, Debian, CentOS."
    exit 0
fi

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This bash required root permission."
    exit 0
fi

AVAILABLE_VERSION=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0")

VERSION=""

read -s "PHP Version: " VERSION

while [[ ! " ${AVAILABLE_VERSION[@]} " =~ " ${VERSION} " ]] do
    echo "Your input version($VERSION) not supported, please enter another one."
    read -s "PHP Version: " VERSION
done

if ! hash nginx; then
    echo "Detected nginx not yet installed, will install nginx first."
    if hash apt; then
        apt -y install nginx
    elif hash dnf; then
        dnf -y install nginx
    elif hash yum; then
        yum -y install nginx
    fi
    
    # make sure linux firewall is opened for Nginx
    if hash ufw; then
        ufw allow 'Nginx HTTP'
        ufw allow 'Nginx HTTPS'
    elif hash firewall-cmd; then
        firewall-cmd --permanent --zone=public --add-service=https --add-service=http
        firewall-cmd --reload
    fi
fi

EXTENDSIONS=("fpm" "bcmath" "common" "curl" "json" "mysql" "mbstring" "xml" "zip" "gd" "soap" "ssh2" "tokenizer" "intl" "xsl" "mcrypt")

function build_extension_string(){
    concated_string=""
    foreach ext EXTENDSIONS
        concated_string+="$1${ext}"
    end
    echo concated_string
}

if [ LINUX_OS -eq "Ubuntu" ]; then
    # install repository
    apt -y install software-properties-common
    add-apt-repository ppa:ondrej/php
    apt update
    # support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
    eval "apt -y install openssl php${VERSION} $(build_extension_string "php${VERSION}-")"
elif [ LINUX_OS -eq "Debian" ]; then
    # install repository
    apt -y install lsb-release apt-transport-https ca-certificates
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    apt update
    # support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
    eval "apt -y install openssl php${VERSION} $(build_extension_string "php${VERSION}-")"
elif [ LINUX_OS -eq "CentOS" ]; then
    # install repository
    yum -y install epel-release
    yum -y install https://rpms.remirepo.net/enterprise/remi-release-$CENTOS_MAJOR_VERSION.rpm
    yum makecache
    # support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
    eval "yum -y install openssl php${VERSION/\./} $(build_extension_string "php${VERSION/\./}-php-")"
fi

tput reset
echo "Successful install Nginx and PHP with version: $VERSION"
