#!/bin/bash

# Capture the version of linux
# 1 = Ubuntu
# 2 = Debian
# 3 = CentOS
# 4 = others
function capture_linux_version(){
    if lsb_release -d | grep -q "Ubuntu"; then
        echo 1
    elif lsb_release -d | grep -q "Debian"; then
        echo 2
    elif lsb_release -d | grep -q "CentOS"; then
        echo 3
    else
        echo 4
    fi
}
