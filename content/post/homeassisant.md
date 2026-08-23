---
title: homeassisant 安裝
toc: true
date: 2026-05-19
---
預設用PVE Script 安裝完VM,結束後用 `homeassisant.local:8123`  
HACS  OS/Core 都可以安裝 `https://hacs.xyz/docs/use/download/download/`  
如果HA 一樣是用 docker 裝 container 或 core 版本，那麼，也是宣告了你沒有 Add-ons 可以用
- File editor
- MQTT + HASS.Agent
- Mosquitto MQTT Broker
- Cloudflared
橋接 Google Nest Mini 2 跟 HomeAssisant：Home Assistant Matter Hub

## configuration.yaml
1. 一般可透過`configuration.yaml` 進行細項，雖然可透過 Terminal修改，但大家還是會透過File Editor 設定，安裝為附加元件：設定 /應用程式/安裝應用程式/File Editor
![](static/Pasted%20image%2020260823102058.png)

2. 打開File Editor 並存檔
![](static/Pasted%20image%2020260823104600.png)
3. 重啟HA並讓`configuration.yaml`重新載入，可透過外掛Terminal & SSH 輸入 `ha core restart` 
![](static/Pasted%20image%2020260823105048.png)
4. 設定/工具/操作，去尋找Shutdown_remote_pc並去執行是否成功
![](static/Pasted%20image%2020260823105431.png)
5. 新增一個關機Button
![](static/Pasted%20image%2020260823111300.png)


bash
```
      timeout 2 sshpass -p 'Password' ssh root@192.168.8.12 'shutdown -h now';
      timeout 2 sshpass -p 'Password' ssh root@192.168.8.14 'shutdown -h now';
      timeout 2 sshpass -p 'Password' ssh root@192.168.8.16 'shutdown -h now';
      timeout 2 sshpass -p 'Password' ssh root@192.168.8.17 'poweroff';
      timeout 2 sshpass -p 'Password' ssh PIN@192.168.8.103 'shutdown /s /t 0';
      timeout 2 sshpass -p 'Password' ssh root@192.168.8.18 'poweroff';
      timeout 2 sshpass -p 'Password' ssh root@192.168.1.5 'shutdown -h now';
```


## Terminal

Terminal 鍵入 docker exec -it homeassistant bash 這行指令：
chris@chris-Default-string:~$ docker exec -it homeassistant bash
chris@chris-Default-string:~$bash-5.1# wget -q -O - https://install.hacs.xyz | bash
