#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This bash required root permission."
    exit 1
fi

function install_nginx(){
    if ! hash nginx 2>/dev/null; then
        echo "Detected nginx not yet installed, will install nginx first."
        if hash apt 2>/dev/null; then
            apt update
            apt -y install nginx
        elif hash dnf 2>/dev/null; then
            dnf -y install nginx
        elif hash yum 2>/dev/null; then
            yum -y install nginx
        fi
    fi

    # make sure linux firewall is opened for Apache
    if hash ufw 2>/dev/null; then
        ufw allow 'Nginx HTTP'
        ufw allow 'Nginx HTTPS'
    elif hash firewall-cmd 2>/dev/null; then
        firewall-cmd --permanent --zone=public --add-service=https --add-service=http
        firewall-cmd --reload
    fi
}

function print_nginx_finish(){
    echo "Successful install Nginx."
    echo "Tips: you could run \`systemctl status nginx\` to view Nginx status."
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

    install_nginx
    print_nginx_finish
 fi
