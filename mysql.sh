#!/bin/bash

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

# --------------------------------------------------------------------------------
# string LINUX_OS=?
# int UBUNTU_MAJOR_VERSION=?
# int CENTOS_MAJOR_VERSION=?
# install_mysql(string PRESET_PASSWORD)
# --------------------------------------------------------------------------------
function install_mysql(){
    if [ ! -n "$LINUX_OS" ]; then
        echo "Please provide LINUX_OS variable."
        return 1
    fi
    if [ ! -n "$UBUNTU_MAJOR_VERSION" ]; then
        echo "Please provide UBUNTU_MAJOR_VERSION variable."
        return 1
    fi
    if [ ! -n "$CENTOS_MAJOR_VERSION" ]; then
        echo "Please provide CENTOS_MAJOR_VERSION variable."
        return 1
    fi
    
    # used for installation and fallback
    DEFAULT_PASSWORD="rootroot"
    # used for login after installation
    PRESET_PASSWORD=${1:-"P@ssw0rd"}

    # determine should it start mysql_secure_installation
    SHOULD_EXECUTE_SECURE_INSTALLATION=0

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
        if [[ $LINUX_OS == "Ubuntu" ]] || [[ $LINUX_OS == "Debian" ]]; then
            echo "mysql-community-server mysql-community-server/root-pass password ${DEFAULT_PASSWORD}" | debconf-set-selections
            echo "mysql-community-server mysql-community-server/re-root-pass password ${DEFAULT_PASSWORD}" | debconf-set-selections
            # Ubuntu 20.x installation package not support MySQL 5.7, fallback to previous version
            if [[ $LINUX_OS == "Ubuntu" ]] && [ $UBUNTU_MAJOR_VERSION -ge 20 ] && [[ $VERSION == "5.7" ]]; then
                echo "mysql-apt-config mysql-apt-config/repo-codename select bionic" | debconf-set-selections
                echo "mysql-apt-config mysql-apt-config/select-server select mysql-${VERSION}" | debconf-set-selections
                curl -sL https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb -o ./mysql_config.deb
                DEBIAN_FRONTEND=noninteractive dpkg -i ./mysql_config.deb
                apt update
                DEBIAN_FRONTEND=noninteractive apt -y install -f mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7*
                
                # prevent package upgrade
                PACKAGE_VERSION=$(apt-cache policy mysql-server | grep 5.7 | head -1 | xargs | cut -d ' ' -f 1)
                ehco "Package: mysql-server" | tee -a /etc/apt/preferences.d/mysql
                ehco "Pin: version $PACKAGE_VERSION" | tee -a /etc/apt/preferences.d/mysql
                ehco "Pin-Priority: 1001" | tee -a /etc/apt/preferences.d/mysql
                ehco "Package: mysql-client" | tee -a /etc/apt/preferences.d/mysql
                ehco "Pin: version $PACKAGE_VERSION" | tee -a /etc/apt/preferences.d/mysql
                ehco "Pin-Priority: 1001" | tee -a /etc/apt/preferences.d/mysql
                ehco "Package: mysql-community-client" | tee -a /etc/apt/preferences.d/mysql
                ehco "Pin: version $PACKAGE_VERSION" | tee -a /etc/apt/preferences.d/mysql
                ehco "Pin-Priority: 1001" | tee -a /etc/apt/preferences.d/mysql
            else
                echo "mysql-apt-config mysql-apt-config/select-server select mysql-${VERSION}" | debconf-set-selections
                echo "mysql-community-server mysql-community-server/default_authentication_plugin select caching_sha2_password" | debconf-set-selections
                curl -sL https://dev.mysql.com/get/mysql-apt-config_0.8.17-1_all.deb -o ./mysql_config.deb
                DEBIAN_FRONTEND=noninteractive dpkg -i ./mysql_config.deb
                apt update
                DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
                apt -y install libncurses5 libaio1 libmecab2 libmysqlclient21
            fi
            rm -f ./mysql_config.deb
            SHOULD_EXECUTE_SECURE_INSTALLATION=1
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
            SHOULD_EXECUTE_SECURE_INSTALLATION=1
        fi
        
        if [ $SHOULD_EXECUTE_SECURE_INSTALLATION -eq 1 ]; then
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
            mysql -h "127.0.0.1" -u "root" $P_COMMAND --connect-expired-password -e "UNINSTALL COMPONENT 'file://component_validate_password'; -- MySQL 8"
            mysql -h "127.0.0.1" -u "root" $P_COMMAND --connect-expired-password -e "UNINSTALL PLUGIN validate_password; -- Others Version"
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

    # capture_linux_version from common.sh
    LINUX_OS=$(capture_linux_version)
    # capture_centos_major_verison from common.sh
    CENTOS_MAJOR_VERSION=$(capture_centos_major_verison)
    # capture_ubuntu_major_version from common.sh
    UBUNTU_MAJOR_VERSION=$(capture_ubuntu_major_version)
 
    install_mysql
 fi
