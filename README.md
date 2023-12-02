# warp-reg.sh
Thanks: [XTLS/Xray-install](https://github.com/XTLS/Xray-install),[@fscarmen](https://github.com/fscarmen/), [fscarmen/warp](https://gitlab.com/fscarmen/warp/), [@badafans](https://github.com/badafans), [badafans/warp-reg](https://github.com/badafans/warp-reg)<br>
## Run
```bash
bash -c "$(curl -L warp-reg.vercel.app)"
```
## Output:
```json
{
    "endpoint":{
       "v4": "162.159.192.10",
       "v6": "[2606:4700:d0::a29f:c00a]",
    },
    "reserved_dec": [225,76,129],
    "reserved_hex": "0xe14c81",
    "private_key": "IDJ/MHXvu5W29fNxy13uyqluSM8TgoYtwuWmWBVGR24=",
    "public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
    "v4": "172.16.0.2",
    "v6": "2606:4700:110:8aa7:cda2:ffbd:c68e:b126"
}
```