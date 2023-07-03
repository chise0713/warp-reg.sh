#!/bin/bash
# Get
curl -sLo /tmp/warp-reg \
 https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64 \
 && chmod +x /tmp/warp-reg && /tmp/warp-reg >> /tmp/warp-reg.ini 
private_key=$(grep private_key: /tmp/warp-reg.ini)
public_key=$(grep public_key: /tmp/warp-reg.ini)
reserved=$(grep reserved: /tmp/warp-reg.ini)
v6=$(grep v6: /tmp/warp-reg.ini)

# Clean up variables
private_key=${private_key#private_key: } 
public_key=${public_key#public_key: } 
reserved=${reserved#reserved: } 
v6=${v6#v6: } 

# Print variables
echo private_key=$private_key
echo public_key=$public_key
echo reserved=$reserved
echo v6=$v6

sleep 0.2
# BackUp
cp config.json config_new.json
# Replace
sed -i "s#_REPLACE_WITH_private_key_#${private_key}#g" config_new.json
sed -i "s#_REPLACE_WITH_public_key_#${public_key}#g" config_new.json
sed -i "s#_REPLACE_WITH_reserved_#${reserved}#g" config_new.json
sed -i "s#_REPLACE_WITH_v6_#${v6}#g" config_new.json

# Remove TempFile
rm /tmp/warp-reg.ini
rm /tmp/warp-reg