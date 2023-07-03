# warp-reg.sh
[Upstream URL](https://github.com/badafans/warp-reg)  
Ready-made config files in [release branch](https://github.com/KoinuDayo/warp-reg.sh/tree/release)  
[![Generate Cloudflare WARP wireguard config for Xray](https://github.com/KoinuDayo/warp-reg.sh/actions/workflows/generate.yaml/badge.svg)](https://github.com/KoinuDayo/warp-reg.sh/actions/workflows/generate.yaml)
# How To Use?
  1. Put your `config.json` in the directory  
  2. Add a `wireguard` in your `outbound`.  
  Like this
  ```json
        {
            "protocol": "wireguard",
            "settings": {
                "secretKey": "_REPLACE_WITH_private_key_", 
                "address": [
                    "172.16.0.2/32",
                    "_REPLACE_WITH_v6_/128" 
                ],
                "peers": [
                    {
                        "publicKey": "_REPLACE_WITH_public_key_",
                        "allowedIPs": [
                            "0.0.0.0/0",
                            "::/0"
                        ],
                        "endpoint": "engage.cloudflareclient.com:2408"
                    }
                ],
                "reserved":_REPLACE_WITH_reserved_,
                "mtu": 1280
            },
            "tag": "wireguard"
        }
  ```
  3. Run this command
```
bash -c "$(curl -L https://raw.githubusercontent.com/KoinuDayo/warp-reg.sh/main/warp-reg.sh)"
```
  4. Done

# Example
### Before
```json
{
    "protocol": "wireguard",
    "settings": {
        "secretKey": "_REPLACE_WITH_private_key_", 
        "address": [
            "172.16.0.2/32",
            "_REPLACE_WITH_v6_/128" 
        ],
        "peers": [
            {
                "publicKey": "_REPLACE_WITH_public_key_",
                "allowedIPs": [
                    "0.0.0.0/0",
                    "::/0"
                ],
                "endpoint": "engage.cloudflareclient.com:2408"
            }
        ],
        "reserved":_REPLACE_WITH_reserved_,
        "mtu": 1280
    },
    "tag": "wireguard"
}
```
### After
```json
{
    "protocol": "wireguard",
    "settings": {
        "secretKey": "wMwh0OuzW5pLhH8a95lQ7APMejGLrpRPKhVQ4+nEkWc=", 
        "address": [
            "172.16.0.2/32",
            "2606:4700:110:8033:e915:b35a:372f:fb32/128" 
        ],
        "peers": [
            {
                "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                "allowedIPs": [
                    "0.0.0.0/0",
                    "::/0"
                ],
                "endpoint": "engage.cloudflareclient.com:2408"
            }
        ],
        "reserved":[ 30, 83, 255 ],
        "mtu": 1280
    },
    "tag": "wireguard"
}
```
