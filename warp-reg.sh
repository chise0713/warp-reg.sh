#!/usr/bin/bash
ERROR="\e[1;31m"
WARN="\e[93m"
END="\e[0m"

package_manager() {
    if [[ "$(type -P apt)" ]]; then
        PACKAGE_MANAGEMENT_INSTALL='apt -y --no-install-recommends install'
        PACKAGE_MANAGEMENT_REMOVE='apt purge'
        package_provide_tput='ncurses-bin'
    elif [[ "$(type -P dnf)" ]]; then
        PACKAGE_MANAGEMENT_INSTALL='dnf -y install'
        PACKAGE_MANAGEMENT_REMOVE='dnf remove'
        package_provide_tput='ncurses'
    elif [[ "$(type -P yum)" ]]; then
        PACKAGE_MANAGEMENT_INSTALL='yum -y install'
        PACKAGE_MANAGEMENT_REMOVE='yum remove'
        package_provide_tput='ncurses'
    elif [[ "$(type -P zypper)" ]]; then
        PACKAGE_MANAGEMENT_INSTALL='zypper install -y --no-recommends'
        PACKAGE_MANAGEMENT_REMOVE='zypper remove'
        package_provide_tput='ncurses-utils'
    elif [[ "$(type -P pacman)" ]]; then
        PACKAGE_MANAGEMENT_INSTALL='pacman -Syu --noconfirm'
        PACKAGE_MANAGEMENT_REMOVE='pacman -Rsn'
        package_provide_tput='ncurses'
     elif [[ "$(type -P emerge)" ]]; then
        PACKAGE_MANAGEMENT_INSTALL='emerge -qv'
        PACKAGE_MANAGEMENT_REMOVE='emerge -Cv'
        package_provide_tput='ncurses'
    else
        echo -e "${ERROR}ERROR:${END} The script does not support the package manager in this operating system."
        exit 1
    fi
}

install_software() {
    package_name="$1"
    file_to_detect="$2"
    type -P "$file_to_detect" > /dev/null 2>&1 && return || echo -e "${WARN}WARN:${END} $package_name not installed, installing."
    if ${PACKAGE_MANAGEMENT_INSTALL} "$package_name" >/dev/null 2>&1; then
        echo "INFO: $package_name is installed."
    else
        echo -e "${ERROR}ERROR:${END} Installation of $package_name failed, please check your network."
        exit 1
    fi
}

reg() {
    private_key=$(wg genkey)
    public_key=$(echo "$private_key" | wg pubkey)
    curl -X POST 'https://api.cloudflareclient.com/v0a2158/reg' -sL --tlsv1.3 \
    -H 'CF-Client-Version: a-7.21-0721' -H 'Content-Type: application/json' \
    -d \
   '{
        "key":"'${public_key}'",
        "tos":"'$(date +"%Y-%m-%dT%H:%M:%S.000Z")'"
    }' \
        | python3 -m json.tool | sed "/\"account_type\"/i\         \"private_key\": \"$private_key\","
}

main() {
    package_manager
    install_software 'wireguard-tools' 'wg'
    warp_info=$(reg)
    exit=$?
    if [[ $exit != 0 ]];then
        echo "$warp_info"
        echo -e "${ERROR}ERROR:${END} \"reg\" function returned a none zero exit code, exiting."
        exit $exit
    else
        echo "{
    \"endpoint\":{"
        echo "$warp_info" | grep -P "(v4|v6)" | grep -vP "(\"v4\": \"172.16.0.2\"|\"v6\": \"2)" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/^"/       "/g' | sed 's/:0",$/",/g'
        echo '    },'
        echo "$warp_info" | grep -P "(private_key|public_key|\"v4\": \"172.16.0.2\"|\"v6\": \"2)" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/^"/    "/g'
        echo "}"
    fi
}

main

