---
title: homeassisant 安裝
toc: true
date: 2026-05-19
---
預設用PVE Script 安裝完VM,結束後用 `homeassisant.local:8123`  
HACS  OS/Core 都可以安裝 `https://hacs.xyz/docs/use/download/download/`  

如果你的 HA 一樣是用 docker 裝 container 或 core 版本，那麼，也是宣告了你沒有 Add-ons 可以用
File editor
MQTT + HASS.Agent
Mosquitto MQTT Broker
Cloudflared
橋接 Google Nest Mini 2 跟 HomeAssisant：Home Assistant Matter Hub



雖然可以用 Terminal 進去修改 HA 裡的 configuration.yaml，但此時想要加入 HACS 就變得麻煩，因為在之前文章裡，安裝 HACS 是用 File Editor，如果你沒有 File Editor，wget -q -O - https://install.hacs.xyz | bash - 這行指令就不知道要在哪裡輸入。

其實跟 Terminal 段落一樣，我們一樣要先進到 Ubuntu，但此時不是進到 HA 的資料夾裡，而是鍵入 docker exec -it homeassistant bash 這行指令，會得到如下結果：

chris@chris-Default-string:~$ docker exec -it homeassistant bash
bash-5.1# 
於是就可以在 bash-5.1# 後面執行wget -q -O - https://install.hacs.xyz | bash -這行指令，並安裝你的 HACS 了