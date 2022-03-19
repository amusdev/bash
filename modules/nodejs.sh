#!/bin/bash

if [ -z ${BASH_COMMON_DEFINE+x} ]; then
    if [ ! -f ../common.sh ]; then
        source <(curl -s https://amusdev.github.io/bash/common.sh)
    else
        source ../common.sh
    fi
fi

NODEJS_AVAILABLE_VERSION=("10" "11" "12" "13" "14" "15" "16")
NPM_AVAILABLE_VERSION=("5" "6" "7")

function require_nodejs_version_from_cli(){
    local version=""
    while read -p "Node.js Version: " version < /dev/tty && [[ ! " ${NODEJS_AVAILABLE_VERSION[@]} " =~ " ${version} " ]];
    do
        echo -e "${ERROR_STYLE}The Node.js version($version) you typed is not supported, please enter another one.\e[0m"
        echo "Supported versions are (${NODEJS_AVAILABLE_VERSION[*]})"
    done
    eval "$1=$version"
}

function require_npm_version_from_cli(){
    local version=""
    while read -p "NPM Version: " version < /dev/tty && [[ ! " ${NPM_AVAILABLE_VERSION[@]} " =~ " ${version} " ]];
    do
        echo -e "${ERROR_STYLE}The npm version($version) you typed is not supported, please enter another one.\e[0m"
        echo "Supported versions are (${NPM_AVAILABLE_VERSION[*]})"
    done
    eval "$1=$version"
}

# ------------------------------------------------------
# install_nodejs_check_available(string nodejs_version, string npm_version)
# ------------------------------------------------------
function install_nodejs_check_available(){
    local nodejs_version=$1
    local npm_version=$2

    if [[ ! " ${NODEJS_AVAILABLE_VERSION[@]} " =~ " ${nodejs_version} " ]]; then
        echo -e "${ERROR_STYLE}The Node.js version($nodejs_version) you typed is not supported.\e[0m"
        exit 1
    fi
    if [[ ! " ${NPM_AVAILABLE_VERSION[@]} " =~ " ${npm_version} " ]]; then
        echo -e "${ERROR_STYLE}The npm version($npm_version) you typed is not supported.\e[0m"
        exit 1
    fi
}

# ------------------------------------------------------
# install_nodejs(string nodejs_version, string npm_version)
# ------------------------------------------------------
function install_nodejs(){
    # capture_linux_version from common.sh
    local os=$(capture_linux_version)
    local nodejs_version=$1
    local npm_version=$2

    install_nodejs_check_available $nodejs_version $npm_version

    if [[ $os == "Ubuntu" ]] || [[ $os == "Debian" ]]; then
        apt-get install -y apt-transport-https curl software-properties-common
        curl -sL https://deb.nodesource.com/setup_${nodejs_version}.x | bash -
        apt-get install -y nodejs gcc
    else
        curl -sL https://rpm.nodesource.com/setup_${nodejs_version}.x | bash -
        yum install -y nodejs
        # Install gcc 5.0+
        yum -y install centos-release-scl
        yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++
    fi

    npm install -g npm@${npm_version}
}

function print_nodejs_finish(){
    echo "Node.js >>"
    echo -e "${INFO_STYLE}The system finished installing Node.js with version: ${VERSION_STYLE}$1\e[0m"
    echo -e "${INFO_STYLE}NPM version: ${VERSION_STYLE}$2\e[0m"
}
