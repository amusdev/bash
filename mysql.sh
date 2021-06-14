#!/bin/bash

DEFAULT_PASSWORD="rootroot"

MYSQL57_FALLBACK_REPO="[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
enabled=1
gpgcheck=0

[mysql-connectors-community]
name=MySQL Connectors Community
baseurl=http://repo.mysql.com/yum/mysql-connectors-community/el/7/\$basearch/
enabled=1
gpgcheck=0

[mysql-tools-community]
name=MySQL Tools Community
baseurl=http://repo.mysql.com/yum/mysql-tools-community/el/7/\$basearch/
enabled=1
gpgcheck=0"

# --------------------------------------------------------
# install_mysql(string LINUX_OS, int CENTOS_MAJOR_VERSION)
# --------------------------------------------------------
function install_mysql(){
    LINUX_OS=$1
    CENTOS_MAJOR_VERSION=$2
    
    AVAILABLE_VERSION=("5.7" "8.0")

    while read -p "MySQL Version: " VERSION < /dev/tty && [[ ! " ${AVAILABLE_VERSION[@]} " =~ " ${VERSION} " ]];
    do
        echo "Your inputted version($VERSION) is not supported, please enter another one."
        echo "Support versions are (${AVAILABLE_VERSION[*]})"
    done
    
    if ! hash mysqld 2>/dev/null; then
        executed=0
        if [[ $LINUX_OS == "Ubuntu" ]] || [[ $LINUX_OS == "Debian" ]]; then
            curl -sL https://dev.mysql.com/get/mysql-apt-config_0.8.17-1_all.deb -o ./mysql_config.deb
            echo "mysql-community-server mysql-community-server/root-pass password ${DEFAULT_PASSWORD}" | debconf-set-selections
            echo "mysql-community-server mysql-community-server/re-root-pass password ${DEFAULT_PASSWORD}" | debconf-set-selections
            echo "mysql-apt-config mysql-apt-config/select-server select mysql-${VERSION}" | debconf-set-selections
            DEBIAN_FRONTEND=noninteractive dpkg -i ./mysql_config.deb
            apt update
            DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
            executed=1
        elif [[ $LINUX_OS == "CentOS" ]]; then
            if [ CENTOS_MAJOR_VERSION -ge 8 ]; then
                if [[ $VERSION == "8.0" ]]; then
                    yum -y install mysql-server
                elif [[ $VERISON == "5.7" ]]; then
                    yum -y remove @mysql
                    yum module reset mysql && yum module disable mysql
                    $MYSQL57_FALLBACK_REPO >> /etc/yum.repos.d/mysql-community.repo
                    # make sure other verison repo is disabled
                    yum config-manager --disable mysql80-community
                    yum config-manager --enable mysql57-community
                    yum -y install mysql-community-server
                fi
            else
                if [[ $VERSION == "8.0" ]]; then
                    yum -y install https://repo.mysql.com/mysql80-community-release-el${CENTOS_MAJOR_VERSION}-3.noarch.rpm
                    yum -y install mysql-community-server
                elif [[ $VERISON == "5.7" ]]; then
                    yum localinstall https://dev.mysql.com/get/mysql57-community-release-el${CENTOS_MAJOR_VERSION}-8.noarch.rpm
                    yum -y install mysql-community-server
                fi
            fi
            generated_pwd=$(grep 'A temporary password' /var/log/mysqld.log |tail -1)
            DEFAULT_PASSWORD=$(echo ${generated_pwd#*":"} | xargs)
            sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
            yum -y --enablerepo=mysql${VERSION/\./}-community install mysql-community-server
            executed=1
        fi
        
        if [ $executed -eq 1 ]; then
            # mysql_secure_installation
            # New password
            mysql -h "localhost" -u "root" -p $DEFAULT_PASSWORD -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"
            # Remove anonymous users
            mysql -h "localhost" -u "root" -p $DEFAULT_PASSWORD -e "DROP USER ''@'localhost'"
            # Because our hostname varies we'll use some Bash magic here.
            mysql -h "localhost" -u "root" -p $DEFAULT_PASSWORD -e "DROP USER ''@'$(hostname)'"
            # Remove test database and access to it
            mysql -h "localhost" -u "root" -p $DEFAULT_PASSWORD -e "DROP DATABASE IF EXIST test"
            # Reload privilege tables now
            mysql -h "localhost" -u "root" -p $DEFAULT_PASSWORD -e "FLUSH PRIVILEGES;"
        fi
    fi
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
    # todo: centos min 6

    # capture_linux_version from common.sh
    LINUX_OS=$(capture_linux_version)
    # capture_centos_major_verison from common.sh
    CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)
 
    install_mysql $LINUX_OS $CENTOS_MAJOR_VERSION
 fi
