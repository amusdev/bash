#!/bin/bash

BASH_COMMON_DEFINE=1

INFO_STYLE="\e[32m"
ERROR_STYLE="\e[31m"
COMMEND_STYLE="\e[36m"
VERSION_STYLE="\e[91m"

# Capture the version of linux
# return Ubuntu | Debian | CentOS | others
function capture_linux_version(){
    # install required extension `lsb_release`
    if ! hash lsb_release 2>/dev/null; then
        if hash yum 2>/dev/null; then
            yum install -y redhat-lsb-core
        elif hash apt-get 2>/dev/null; then
            apt-get update && apt-get install -y lsb-release && apt-get clean all
        fi
    fi
    # start checking os version
    if hash lsb_release 2>/dev/null; then
        if lsb_release -si | grep -q "Ubuntu"; then
            echo "Ubuntu"
        elif lsb_release -si | grep -q "Debian"; then
            echo "Debian"
        elif lsb_release -si | grep -q "CentOS"; then
            echo "CentOS"
        else
            echo "Others"
        fi
    elif hash hostnamectl 2>/dev/null; then
        if hostnamectl | grep -q "Ubuntu"; then
            echo "Ubuntu"
        elif hostnamectl | grep -q "Debian"; then
            echo "Debian"
        elif hostnamectl | grep -q "CentOS"; then
            echo "CentOS"
        else
            echo "Others"
        fi
    else
        echo "Others"
    fi
}

# Capture CentOS major version
# eg. 6.1.1028
# will capture 6
function capture_centos_major_verison(){
    if hash rpm 2>/dev/null; then
        local version=$(rpm --eval '%{centos}')
    fi
    expr ${version:-0}
}

# Capture Ubuntu major version
# eg. 20.04
# will capture 20
function capture_ubuntu_major_version(){
    local version=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d '=' -f 2 | cut -d '.' -f 1)
    expr ${version:-0}
}

# Environment checking
function check_env(){
    local linux_os=$(capture_linux_version)
    local centos_major=$(capture_centos_major_verison)
    local ubuntu_major=$(capture_ubuntu_major_version)

    if [[ $linux_os == "Others" ]]; then
        local version_in_scope=0
    elif [[ $linux_os == "Ubuntu" ]] && { [ $ubuntu_major -lt 16 ] || [ $ubuntu_major -gt 20 ]; }; then
        local version_in_scope=0
    elif [[ $linux_os == "CentOS" ]] && { [ $centos_major -lt 6 ] || [ $centos_major -gt 8 ]; }; then
        local version_in_scope=0
    else
        local version_in_scope=1
    fi

    if [[ $version_in_scope -ne 1 ]]; then
        echo -e "This bash only executable on Ubuntu, Debian, CentOS.\nLearn more in https://github.com/amusdev/bash#support-environments"
        exit 1
    elif [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This bash required root permission."
        exit 1
    fi
}

# import_from_local_or_remote(string file)
function import_from_local_or_remote(){
    local file=$1
    if [ ! -f "./$file" ]; then
        source <(curl -s "https://amusdev.github.io/bash/$file")
    else
        source "./$file"
    fi
}