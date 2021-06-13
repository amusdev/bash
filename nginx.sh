#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This bash required root permission."
    exit 1
fi

function install_nginx(){
    if ! hash nginx; then
        echo "Detected nginx not yet installed, will install nginx first."
        if hash apt; then
            apt update
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
}

function print_nginx_finish(){
    echo "Successful install Nginx."
    echo "Tips: you could run \`systemctl nginx status\` to view Nginx status."
}

([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] || 
 [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
    printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] || 
 [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)) && IS_SOURCED_BASH=1 || IS_SOURCED_BASH=0
 
 if [ $IS_SOURCED_BASH -eq 0 ]; then
    install_nginx
    print_nginx_finish
 fi
