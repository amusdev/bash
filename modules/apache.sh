#!/bin/bash

if [ -z ${BASH_COMMON_DEFINE+x} ]; then
    if [ ! -f ../common.sh ]; then
        source <(curl -s https://amusdev.github.io/bash/common.sh)
    else
        source ../common.sh
    fi
fi

function install_apache(){
    if ! hash apache2 2>/dev/null; then
        if hash apt 2>/dev/null; then
            apt update
            apt -y install apache2
        elif hash dnf 2>/dev/null; then
            dnf -y update httpd
            dnf -y install httpd
        elif hash yum 2>/dev/null; then
            yum -y update httpd
            yum -y install httpd
        fi
    fi
    
    # make sure linux firewall is opened for Apache
    if hash ufw 2>/dev/null; then
        ufw allow 'Apache'
        ufw allow 'Apache Secure'
    elif hash firewall-cmd 2>/dev/null; then
        firewall-cmd --permanent --zone=public --add-service=https --add-service=http
        firewall-cmd --reload
    fi

    # Apache does not automatically start on
    systemctl start httpd
}

function print_apache_finish(){
    # capture_linux_version from common.sh
    local os=$(capture_linux_version)
    echo "Apache >>"
    [[ $os == "CentOS" ]] && process="httpd" || process="apache2"
    echo -e "${INFO_STYLE}The system finished installing Apache2.\e[0m"
    echo -e "Tips: you could run ${COMMEND_STYLE}systemctl status ${process}\e[0m or ${COMMEND_STYLE}service ${process} status\e[0m to view Apache2 status."
}