#!/bin/bash

if [ -z ${BASH_COMMON_DEFINE+x} ]; then
    if [ ! -f ../common.sh ]; then
        source <(curl -s https://amusdev.github.io/bash/common.sh)
    else
        source ../common.sh
    fi
fi

MYSQL_AVAILABLE_VERSIONS=("5.7" "8.0")

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

function require_mysql_version_from_cli(){
    # capture_linux_version from common.sh
    local os=$(capture_linux_version)
    # capture_centos_major_verison from common.sh
    local centos_major=$(capture_centos_major_verison)
    local version=""
    while true;
    do
        read -p "MySQL Version: " version < /dev/tty
        if [[ ! " ${MYSQL_AVAILABLE_VERSIONS[@]} " =~ " ${version} " ]]; then
            echo -e "${ERROR_STYLE}The MySQL version($version) you typed is not supported, please enter another one.\e[0m"
            echo "Supported versions are (${MYSQL_AVAILABLE_VERSIONS[*]})"
        elif [[ $os == "CentOS" ]] && [ $centos_major -lt 6 ] && [[ $version == "8.0" ]]; then
            echo -e "${ERROR_STYLE}The MySQL version($version) you typed is not supported, please enter another one.\e[0m"
            echo "Supported versions are (5.7)"
        else
            break
        fi
    done
    eval "$1=$version"
}

# --------------------------------------------------------------------------------
# string[] MYSQL_AVAILABLE_VERSIONS=?
# install_mysql(string VERSION)
# --------------------------------------------------------------------------------
function install_mysql_check_available(){
    local os=$(capture_linux_version)
    local centos_major=$(capture_centos_major_verison)
    local version=$1

    if [[ ! " ${MYSQL_AVAILABLE_VERSIONS[@]} " =~ " ${version} " ]]; then
        echo -e "${ERROR_STYLE}The MySQL version($version) you typed is not supported.\e[0m"
        exit 1
    elif [[ $os == "CentOS" ]] && [ $centos_major -lt 6 ] && [[ $version == "8.0" ]]; then
        echo -e "${ERROR_STYLE}The MySQL version($version) you typed is not supported. CentOS only support v5.7.\e[0m"
        exit 1
    fi
}

# --------------------------------------------------------------------------------
# string[] MYSQL_AVAILABLE_VERSIONS=?
# install_mysql(string VERSION, string? PRESET_PASSWORD)
# --------------------------------------------------------------------------------
function install_mysql(){
    local os=$(capture_linux_version)
    local ubuntu_major=$(capture_ubuntu_major_version)
    local centos_major=$(capture_centos_major_verison)
    
    # used for installation and fallback
    DEFAULT_PASSWORD="rootroot"
    
    if [ "$#" -eq 1 ]; then
        local version=$1
        PRESET_PASSWORD="P@ssw0rd"
    elif [ "$#" -eq 2 ]; then
        local version=$1
        # used for login after installation
        PRESET_PASSWORD=${2:-"P@ssw0rd"}
    fi

    # determine should it start mysql_secure_installation
    SHOULD_EXECUTE_SECURE_INSTALLATION=0
    
    # check version match lists
    if [[ ! " ${MYSQL_AVAILABLE_VERSIONS[@]} " =~ " ${version} " ]]; then
        echo "Your inputted version($version) is not supported."
        exit 1
    elif [[ $os == "CentOS" ]] && [ $centos_major -lt 6 ] && [[ $version == "8.0" ]]; then
        echo "CentOS only support MySQL 5.7"
        exit 1
    fi
    
    if ! hash mysqld 2>/dev/null; then
        if [[ $os == "Ubuntu" ]] || [[ $os == "Debian" ]]; then
            echo "mysql-community-server mysql-community-server/root-pass password ${DEFAULT_PASSWORD}" | debconf-set-selections
            echo "mysql-community-server mysql-community-server/re-root-pass password ${DEFAULT_PASSWORD}" | debconf-set-selections
            # Ubuntu 20.x installation package not support MySQL 5.7, fallback to previous version
            if [[ $os == "Ubuntu" ]] && [ $ubuntu_major -ge 20 ] && [[ $version == "5.7" ]]; then
                echo "mysql-apt-config mysql-apt-config/repo-codename select bionic" | debconf-set-selections
                echo "mysql-apt-config mysql-apt-config/select-server select mysql-${version}" | debconf-set-selections
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
                echo "mysql-apt-config mysql-apt-config/select-server select mysql-${version}" | debconf-set-selections
                echo "mysql-community-server mysql-community-server/default_authentication_plugin select caching_sha2_password" | debconf-set-selections
                curl -sL https://dev.mysql.com/get/mysql-apt-config_0.8.17-1_all.deb -o ./mysql_config.deb
                DEBIAN_FRONTEND=noninteractive dpkg -i ./mysql_config.deb
                apt update
                DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
                apt -y install libncurses5 libaio1 libmecab2 libmysqlclient21
            fi
            rm -f ./mysql_config.deb
            SHOULD_EXECUTE_SECURE_INSTALLATION=1
        elif [[ $os == "CentOS" ]]; then
            if [ $centos_major -ge 8 ]; then
                if [[ $version == "8.0" ]]; then
                    dnf -y install mysql-server
                    systemctl start mysqld.service
                    # start the service on server boots up
                    systemctl enable mysqld
                    DEFAULT_PASSWORD=""
                elif [[ $version == "5.7" ]]; then
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
                if [[ $version == "8.0" ]]; then
                    yum -y install https://repo.mysql.com/mysql80-community-release-el${centos_major}-3.noarch.rpm
                    yum -y install mysql-community-server
                elif [[ $version == "5.7" ]]; then
                    yum -y install https://dev.mysql.com/get/mysql57-community-release-el${centos_major}-8.noarch.rpm
                    yum -y install mysql-community-server
                fi
                sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
                yum -y --enablerepo=mysql${version/\./}-community install mysql-community-server
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

function print_mysql_finish(){
    local version=$1
    local password=$2
    echo "MySQL >>"
    echo -e "${INFO_STYLE}The system finished installing MySQL with version: ${VERSION_STYLE}$version\e[0m"
    echo -e "${INFO_STYLE}The default root password: ${VERSION_STYLE}$password\e[0m"
}