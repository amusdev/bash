#!/bin/bash

if [ -z ${BASH_COMMON_DEFINE+x} ]; then
    if [ ! -f ../common.sh ]; then
        source <(curl -s https://amusdev.github.io/bash/common.sh)
    else
        source ../common.sh
    fi
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
    echo "Nginx >>"
    echo -e "${INFO_STYLE}The system finished installing Nginx.\e[0m"
    echo -e "Tips: you could run ${COMMEND_STYLE}systemctl status nginx\e[0m or ${COMMEND_STYLE}service nginx status\e[0m to view Nginx status."
}