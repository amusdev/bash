#!/bin/bash

# used for installation
DEFAULT_PASSWORD="rootroot"
# used for login after installation
PRESET_PASSWORD="testtest"

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

    while true;
    do
        read -p "MySQL Version: " VERSION < /dev/tty
        if [[ ! " ${AVAILABLE_VERSION[@]} " =~ " ${VERSION} " ]]; then
            echo "Your inputted version($VERSION) is not supported, please enter another one."
            echo "Support versions are (${AVAILABLE_VERSION[*]})"
        elif [[ $LINUX_OS == "CentOS" ]] && [ $CENTOS_MAJOR_VERSION -lt 6 ] && [[ $VERSION == "8.0" ]]; then
            echo "Your inputted version($VERSION) is not supported, please enter another one."
            echo "Support versions are (5.7)"
        else
            break
        fi
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
            #rm -f ./mysql_config.deb
            executed=1
        elif [[ $LINUX_OS == "CentOS" ]]; then
            if [ $CENTOS_MAJOR_VERSION -ge 8 ]; then
                if [[ $VERSION == "8.0" ]]; then
                    dnf -y install mysql-server
                    systemctl start mysqld.service
                    # start the service on server boots up
                    systemctl enable mysqld
                    DEFAULT_PASSWORD=""
                elif [[ $VERSION == "5.7" ]]; then
                    dnf -y remove @mysql
                    dnf -y module reset mysql && dnf -y module disable mysql
                    echo "$MYSQL57_FALLBACK_REPO" | tee -a /etc/yum.repos.d/mysql-community.repo
                    # make sure other verison repo is disabled
                    dnf config-manager --disable mysql80-community
                    dnf config-manager --enable mysql57-community
                    dnf -y install mysql-community-server
                    systemctl start mysqld.service
                    # start the service on server boots up
                    systemctl enable mysqld
                    DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | tail -1 | cut -d '@' -f 2 | cut -d ' ' -f 2)
                fi
            else
                if [[ $VERSION == "8.0" ]]; then
                    yum -y install https://repo.mysql.com/mysql80-community-release-el${CENTOS_MAJOR_VERSION}-3.noarch.rpm
                    yum -y install mysql-community-server
                elif [[ $VERSION == "5.7" ]]; then
                    yum -y install https://dev.mysql.com/get/mysql57-community-release-el${CENTOS_MAJOR_VERSION}-8.noarch.rpm
                    yum -y install mysql-community-server
                fi
                sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
                yum -y --enablerepo=mysql${VERSION/\./}-community install mysql-community-server
                systemctl start mysqld.service
                # start the service on server boots up
                systemctl enable mysqld
                DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | tail -1 | cut -d '@' -f 2 | cut -d ' ' -f 2)
            fi
            executed=1
        fi
        
        if [ $executed -eq 1 ]; then
            if [[ $DEFAULT_PASSWORD == "" ]]; then
                P_COMMAND=""
            else
                P_COMMAND="-p$DEFAULT_PASSWORD"
            fi
            # mysql_secure_installation
            MYSQL_SECURE_INSTALLATION_SCRIPT=";
            # New password
            ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$PRESET_PASSWORD';
            # Remove anonymous users
            DELETE FROM mysql.user WHERE User = '' OR Host NOT IN ('localhost', '127.0.0.1', '::1');
            # Remove test database and access to it
            DROP DATABASE IF EXISTS test;
            # Reload privilege tables
            FLUSH PRIVILEGES;"
            
            # It may throw error if not exists, split out this command
            # Turn off validate password
            mysql -h "127.0.0.1" -u "root" $P_COMMAND --connect-expired-password -e "SET GLOBAL validate_password.policy = 0; -- CentOS MySQL 8"
            mysql -h "127.0.0.1" -u "root" $P_COMMAND --connect-expired-password -e "SET GLOBAL validate_password_policy = 0; -- Others Version"
            mysql -h "127.0.0.1" -u "root" $P_COMMAND --connect-expired-password -e "$MYSQL_SECURE_INSTALLATION_SCRIPT"
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
