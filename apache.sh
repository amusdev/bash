#!/bin/bash

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

# ------------------------------------
# print_apache_finish(string LINUX_OS)
# ------------------------------------
function print_apache_finish(){
    LINUX_OS = $1
    [[ LINUX_OS == "CentOS" ]] && process="httpd" || process="apache2"
    echo "Successful install Apache2."
    echo "Tips: you could run \`systemctl status ${process}\` to view Apache2 status."
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
    fi

    # capture_linux_version from common.sh
    LINUX_OS=$(capture_linux_version)
    # capture_centos_major_verison from common.sh
    CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)
 
    install_apache
    tput reset
    print_apache_finish LINUX_OS
 fi
