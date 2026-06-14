---
title: Session TMOUT
toc: true
date: 2026-06-02
---
Windows 防遠端登出
```
$wsh = New-Object -ComObject WScript.Shell
while($true) {
    # 每 60 秒模擬按下 Scroll Lock 鍵（對系統影響最小的按鍵）
    $wsh.SendKeys('{SCROLLLOCK}')
    Start-Sleep -Seconds 60
}
```

Linux 防遠端登出
ClientAliveInterval 代表主動權在Server身上
export TMOUT=0，效果是時間到Putty直接關閉視窗
sshd_config 設定逾時登出或防火牆設定問題，Putty會出現inactive，

解決方法
1. 阻止putty變inactive，Putty視窗右鍵，Change Settings/Connection，在`Secondsbetweenkeepalives (O to turn off)` 改成30
2. 跳板機 `ssh -o ServerAliveInterval=60 user@jump_server_ip`
3. 輸入以下指令
```
# 迴圈送按鍵大法
while true; do echo -n "\010"; sleep 240; done &
# 每240秒印出系統效能數據
vmstat 240
```





