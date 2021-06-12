#!/bin/bash

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
    apt-get -y install nginx
fi

add-apt-repository ppa:ondrej/php
apt-get update
# support Laravel, Wordpress, Woocommerce, OpenCart, Magento and related program
apt-get -y install openssl php${VERSION} php${VERSION}-fpm php${VERSION}-bcmath php${VERSION}-common php${VERSION}-curl\
    php${VERSION}-json php${VERSION}-mysql php${VERSION}-mbstring php${VERSION}-xml php${VERSION}-zip php${VERSION}-gd\
    php${VERSION}-soap php${VERSION}-ssh2 php${VERSION}-tokenizer php${VERSION}-intl php${VERSION}-xsl php${VERSION}-mcrypt
    
tput reset
echo "Successful install PHP with version: $VERSION"
