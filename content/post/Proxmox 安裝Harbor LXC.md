---
title: Proxmox 安裝 Harbor
toc: true
date: 2026-10-26
---
## Harbor LXC

1. 先建立一個LXC容器，開啟 keyctl=1,nesting=1，並安裝完Docker
wget harbor-online-installer-v2.12.2.tgz，解壓後放在/root/harbor (docker要以root執行)

/root/harbor/harbor.yml
./install.sh --with-trivy

2. TLS 設定
簡而言之：創建文件`server.crt`並`server.key`放入`/data/secrets/cert`。然後，`docker restart nginx`
我一開始沒能正確設定 TLS，但我現在弄清楚了它的工作原理。
- 檢查容器時，它會從和`nginx`讀取憑證檔案。請注意，這些路徑已掛載到容器，因此在主機系統上會有所不同。`/etc/cert/server.crt``/etc/cert/server.key`
- 接下來，我檢查了`nginx`容器，發現所需的掛載點：`/data/secret/cert`已對應到`/etc/cert`容器中。
- 因此，請使用您的 TLS 憑證（理想情況下，只需一個通配符憑證），並將 和`server.crt`放入`server.key`中`/data/secret/cert`。
- 最後，別忘了執行此操作`docker restart nginx`。這是為了讓nginx真正載入新憑證。
- 請不要問我為什麼在設定檔中定義了憑證金鑰和路徑。我不確定它們是否會被使用


3. 保持運行:有時開機不會自己運行，原因未知
```/root/keep-system-running.sh
#!/bin/bash

containers=$(docker ps -a --format "{{ .Names }}")

for container in $containers
do
    running=$(docker inspect $container | jq ".[0].State.Running")
    if [ $running = 'false' ];
    then
        echo "$container is not running; starting it"
        docker start $container
    fi
done

```
設定自動開機
```
chmod +x /root/keep-system-running.sh
crontab -e
*/10 * * * * /root/keep-system-running.sh
```

