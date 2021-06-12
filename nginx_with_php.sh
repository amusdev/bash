#!/bin/bash

source ./common

# capture_linux_version from common.sh
LINUX_VERSION=$(capture_linux_version)

if [ LINUX_VERSION -eq 4 ]; then
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
    apt -y install nginx
    
    # make sure linux firewall is opened for Nginx
    if hash ufw; then
        ufw allow 'Nginx HTTP'
        ufw allow 'Nginx HTTPS'
    fi
fi

if [ LINUX_VERSION -eq 1 ]; then
    # install repository
    apt -y install software-properties-common
    add-apt-repository ppa:ondrej/php
    apt update
    # support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
    apt -y install openssl php${VERSION} php${VERSION}-fpm php${VERSION}-bcmath php${VERSION}-common php${VERSION}-curl\
        php${VERSION}-json php${VERSION}-mysql php${VERSION}-mbstring php${VERSION}-xml php${VERSION}-zip php${VERSION}-gd\
        php${VERSION}-soap php${VERSION}-ssh2 php${VERSION}-tokenizer php${VERSION}-intl php${VERSION}-xsl php${VERSION}-mcrypt
elif [ LINUX_VERSION -eq 2 ]; then
    # install repository
    apt -y install lsb-release apt-transport-https ca-certificates
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    apt update
    # support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
    apt -y install php${VERSION} php${VERSION}-fpm php${VERSION}-bcmath php${VERSION}-common php${VERSION}-curl\
        php${VERSION}-json php${VERSION}-mysql php${VERSION}-mbstring php${VERSION}-xml php${VERSION}-zip php${VERSION}-gd\
        php${VERSION}-soap php${VERSION}-ssh2 php${VERSION}-tokenizer php${VERSION}-intl php${VERSION}-xsl php${VERSION}-mcrypt
elif [ LINUX_VERSION -eq 3]; then
    # TODO
fi

tput reset
echo "Successful install Nginx and PHP with version: $VERSION"
