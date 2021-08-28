#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This bash required root permission."
    exit 1
fi

# ------------------------------------------------------
# string LINUX_OS=?
# install_nodejs(string NODEJS_VERSION, string NPM_VERSION)
# ------------------------------------------------------
function install_nodejs(){
    apt-get install apt-transport-https curl software-properties-common

    NODEJS_AVAILABLE_VERSION=("10" "11" "12" "13" "14" "15" "16")
    NPM_AVAILABLE_VERSION=("5" "6" "7")

    NODEJS_VERSION=$1
    NPM_VERSION=$2

    if [ -z "$NODEJS_VERSION" ]; then
        # parameter not provided
        while read -p "Node.js Version: " NODEJS_VERSION < /dev/tty && [[ ! " ${NODEJS_AVAILABLE_VERSION[@]} " =~ " ${NODEJS_VERSION} " ]];
        do
            echo "Your inputted version($NODEJS_VERSION) is not supported, please enter another one."
            echo "Support versions are (${NODEJS_AVAILABLE_VERSION[*]})"
        done
    else
        # check version match lists
        if [[ ! " ${NODEJS_AVAILABLE_VERSION[@]} " =~ " ${NODEJS_VERSION} " ]]; then
            echo "Your inputted version($NODEJS_VERSION) is not supported."
            exit 1
        fi
    fi

    if [ -z "$NPM_VERSION" ]; then
        # parameter not provided
        while read -p "NPM Version: " NPM_VERSION < /dev/tty && [[ ! " ${NPM_AVAILABLE_VERSION[@]} " =~ " ${NPM_VERSION} " ]];
        do
            echo "Your inputted version($NPM_VERSION) is not supported, please enter another one."
            echo "Support versions are (${NPM_AVAILABLE_VERSION[*]})"
        done
    else
        # check version match lists
        if [[ ! " ${NPM_AVAILABLE_VERSION[@]} " =~ " ${NPM_VERSION} " ]]; then
            echo "Your inputted version($NPM_VERSION) is not supported."
            exit 1
        fi
    fi

    if [[ $LINUX_OS == "Ubuntu" ]] | [[ $LINUX_OS == "Debian" ]];
    then;
        curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | sudo -E bash -
        apt-get install -y nodejs
    else
        curl -sL https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | sudo bash -
        yum install -y nodejs
    fi

    npm install -g npm@${NPM_VERSION}
}

function print_nodejs_finish(){
    echo "Successful install Node.js with version: $NODEJS_VERSION"
    echo "NPM version: $NPM_VERSION"
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
    elif [ $? -eq 2 ] | [ $? -eq 3 ]; then
        echo "Not supported OS, Please refer to minimum support OS to learn more."
    fi

    # capture_linux_version from common.sh
    LINUX_OS=$(capture_linux_version)
    # capture_centos_major_verison from common.sh
    CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)

    NODEJS_VERSION="14"
    NPM_VERSION="7"
    while getopts "v:n:" args;
    do
        case "${args}" in
            v)
                NODEJS_VERSION=${OPTARG}
                ;;
            n)
                NPM_VERSION=${OPTARG}
                ;;
            ;;
        esac
    done

    # OPTARG contains v argurement
    install_nodejs "$NODEJS_VERSION" "$NPM_VERSION"
    tput reset
    print_nodejs_finish
 fi