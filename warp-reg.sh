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
    type -P "$file_to_detect" > /dev/null 2>&1 && return || echo -e "${WARN}WARN:${END} $package_name not installed, installing." && sleep 1
    if ${PACKAGE_MANAGEMENT_INSTALL} "$package_name"; then
        echo "INFO: $package_name is installed."
    else
        echo -e "${ERROR}ERROR:${END} Installation of $package_name failed, please check your network."
        exit 1
    fi
}

reg() {
    set -e
    pipe=/tmp/warp-reg.pipe
    rm $pipe -rf && mkfifo $pipe
    output=$(/tmp/wgg-go)
    private_key=$(echo "$output"|grep 'priv:'| sed 's/priv: //g')
    public_key=$(echo "$output"|grep 'pub:'| sed 's/pub: //g')
    curl -X POST 'https://api.cloudflareclient.com/v0a2158/reg' -sL --tlsv1.3 \
    -H 'CF-Client-Version: a-7.21-0721' -H 'Content-Type: application/json' \
    -d \
   '{
        "key":"'${public_key}'",
        "tos":"'$(date +"%Y-%m-%dT%H:%M:%S.000Z")'"
    }' \
        | python3 -m json.tool | sed "/\"account_type\"/i\         \"private_key\": \"$private_key\","
}

reserved() {
    set -e
    reserved_str=$(echo "$warp_info" | grep 'client_id' | cut -d\" -f4)
    reserved_hex=$(echo "$reserved_str" | base64 -d | xxd -p)
    reserved_dec=$(echo "$reserved_hex" | fold -w2 | while read HEX; do printf '%d ' "0x${HEX}"; done | awk '{print "["$1", "$2", "$3"]"}')
    echo -e "{\n    \"reserved_dec\": $reserved_dec,"
    echo -e "    \"reserved_hex\": \"0x$reserved_hex\","
    echo -e "    \"reserved_str\": \"$reserved_str\"\n}"
}

format() {
    echo "{
    \"endpoint\":{"
    echo "$warp_info" | grep -P "(v4|v6)" | grep -vP "(\"v4\": \"172.16.0.2\"|\"v6\": \"2)" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/^"/       "/g' | sed 's/:0",$/",/g'
    echo '    },'
    echo "$warp_reserved" | grep -P "reserved" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/:\[/: \[/g' | sed 's/\([0-9]\+\),\([0-9]\+\),\([0-9]\+\)/\1, \2, \3/' | sed 's/^"/    "/g' | sed 's/"$/",/g'
    echo "$warp_info" | grep -P "(private_key|public_key|\"v4\": \"172.16.0.2\"|\"v6\": \"2)" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/^"/    "/g'
    echo "}"
}

get-wgg-go() {
	curl -o /tmp/wgg-go -sL warp-reg.vercel.app/wgg-go \
	--next -o /tmp/wgg-go.sha256sum -sL warp-reg.vercel.app/wgg-go.sha256sum &
    wait $!
	local EXPECT_HASH=$(cat "/tmp/wgg-go.sha256sum" | awk '{print $1}')
	local ACTUAL_HASH=$(sha256sum "/tmp/wgg-go" | awk '{print $1}')
	if ! [[ $ACTUAL_HASH == $EXPECT_HASH ]];then
	    echo -e "${ERROR}ERROR:${END} sha256sum Failed.\nRemoving tmpfiles\nExiting."
	    rm /tmp/wgg-go /tmp/wgg-go.sha256sum -f
	    exit 1
	fi
	chmod +x /tmp/wgg-go
}

main() {
    package_manager
    install_software "xxd" "xxd"
    install_software "python3" "python3"
	get-wgg-go
	sleep 5 && rm /tmp/wgg-go /tmp/wgg-go.sha256sum -f &
    warp_info=$(reg) ; exit_code=$?
    if [[ $exit_code != 0 ]];then
        echo "$warp_info"
        echo -e "${ERROR}ERROR:${END} \"reg\" function returned with $exit_code, exiting."
        exit $exit_code
    fi
    warp_reserved=$(reserved) ; exit_code=$?
    if [[ $exit_code != 0 ]];then
        echo "$warp_reserved"
        echo -e "${ERROR}ERROR:${END} \"reserved\" function returned with $exit_code, exiting."
        exit $exit_code
    fi
    format
}

main