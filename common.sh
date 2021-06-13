#!/bin/bash

# Capture the version of linux
# 1 = Ubuntu
# 2 = Debian
# 3 = CentOS
# 4 = others
function capture_linux_version(){
    if hash hostnamectl; then
        if hostnamectl | grep -q "Ubuntu"; then
            echo 1
        elif hostnamectl | grep -q "Debian"; then
            echo 2
        elif hostnamectl | grep -q "CentOS"; then
            echo 3
        else
            echo 4
        fi
    else
        echo 4
    fi
}

# Capture CentOS major version
# eg. 6.1.1028
# will capture 6
function capture_centos_major_verison(){
    echo rpm --eval '%{centos}'
}
