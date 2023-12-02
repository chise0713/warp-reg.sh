#!/usr/bin/bash
set -e
ERROR="\e[1;31m"
WARN="\e[93m"
END="\e[0m"

reg() {
    public_der=$(openssl genpkey -algorithm X25519 -outform der | tr '\0' '\254')
    public_key=$(echo "$public_der" | tr '\254' '\0' | tail -c 32 | base64)
    private_key=$(echo "$public_der" | openssl pkey -inform der -pubout -outform der | tail -c 32 | base64)
    curl -X POST 'https://api.cloudflareclient.com/v0a2158/reg' -sL --tlsv1.3 \
    -H 'CF-Client-Version: a-7.21-0721' -H 'Content-Type: application/json' \
    -d \
   '{
        "key":"'${public_key}'",
        "tos":"'$(date +"%Y-%m-%dT%H:%M:%S.000Z")'"
    }' \
        | python3 -m json.tool | sed "/\"account_type\"/i\         \"private_key\": \"$private_key\"," | cat
}

main() {
    INFO=$(reg)
    echo "{
    \"endpoint\":{"
    echo "$INFO" | grep -P "(v4|v6)" | grep -vP "(\"v4\": \"172.16.0.2\"|\"v6\": \"2)" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/^"/       "/g' | sed 's/:0",$/",/g'
    echo '    },'
    echo "$INFO" | grep -P "(private_key|public_key|\"v4\": \"172.16.0.2\"|\"v6\": \"2)" | sed "s/ //g" | sed 's/:"/: "/g' | sed 's/^"/    "/g'
    echo "}"
}
main

