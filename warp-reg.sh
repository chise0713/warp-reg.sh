#!/usr/bin/bash
ERROR="\e[1;31m"
WARN="\e[93m"
END="\e[0m"

reg() {
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

reservd() {
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
    echo "$warp_reservd" | grep -P "reserved" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/:\[/: \[/g' | sed 's/\([0-9]\+\),\([0-9]\+\),\([0-9]\+\)/\1, \2, \3/' | sed 's/^"/    "/g' | sed 's/"$/",/g'
    echo "$warp_info" | grep -P "(private_key|public_key|\"v4\": \"172.16.0.2\"|\"v6\": \"2)" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/^"/    "/g'
    echo "}"
}

get-wgg-go() {
	curl -o /tmp/wgg-go -sL https://github.com/chise0713/warp-reg.sh/blob/main/wgg-go/wgg-go?raw=true
	curl -o /tmp/wgg-go.sha256sum -sL https://github.com/chise0713/warp-reg.sh/blob/main/wgg-go/wgg-go.sha256sum?raw=true
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
	get-wgg-go
	sleep 5 && rm /tmp/wgg-go /tmp/wgg-go.sha256sum -f &
    warp_info=$(reg) && exit_code=$?
    if [[ $exit_code != 0 ]];then
        echo "$warp_info"
        echo -e "${ERROR}ERROR:${END} \"reg\" function returned with $exit_code, exiting."
        exit $exit_code
    fi
    warp_reservd=$(reservd) && exit_code=$?
    if [[ $exit_code != 0 ]];then
        echo "$warp_reservd"
        echo -e "${ERROR}ERROR:${END} \"reservd\" function returned with $exit_code, exiting."
        exit $exit_code
    fi
    format
}

main