#!/bin/bash

# Capture the version of linux
# 1 = Ubuntu
# 2 = Debian
# 3 = CentOS
# 4 = others
function capture_linux_version(){
    if hash hostnamectl 2>/dev/null; then
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
        version=$(rpm --eval '%{centos}')
    fi
    expr ${version:-0}
}

# Capture Ubuntu major version
# eg. 20.04
# will capture 20
function capture_ubuntu_major_version(){
    version=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d '=' -f 2 | cut -d '.' -f 1)
    expr ${version:-0}
}

# Environment checking
function check_env(){
    if [[ $LINUX_OS == "Others" ]]; then
        return 2
    fi

    if [[ $LINUX_OS == "CentOS" ]]; then
        if [ $CENTOS_MAJOR_VERSION -lt 5 ] || [ $CENTOS_MAJOR_VERSION -gt 8 ]; then
            return 3
        fi
    fi

    if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        return 1
    fi
}
