---
title: Session TMOUT
toc: true
date: 2026-06-02
---
Windows 防止遠端登出

LInux 防遠端登出
export TMOUT=0
跳板機 `ssh -o ServerAliveInterval=60 user@jump_server_ip`
ClientAliveInterval 代表主動權在Server身上

方法2
```
# 迴圈送按鍵大法
while true; do echo -n "\010"; sleep 240; done &
# 每240秒印出系統效能數據
vmstat 240
```


sshd_config 會出現inactive，防火牆設定問題

TMOUT視窗是直接關閉


阻止putty變inactive，Putty視窗右鍵，Change Settings/Connection，在`Secondsbetweenkeepalives (O to turn off)` 改成30


