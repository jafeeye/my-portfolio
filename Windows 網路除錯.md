---
title: Windows 網路除錯
---

| 常用指令排序                | 指令                                                                             | 看什麼                                    |
| --------------------- | ------------------------------------------------------------------------------ | -------------------------------------- |
| 查看 IP、閘道、DNS、MAC      | `ipconfig /all`<br>`gip -InterfaceA "乙太網路 2"`<br>`gip -InterfaceA "乙太網路 2" -d` | IP、DNS 是否設錯，一般的ipconfig無法看DNS          |
| 查看鄰近設備的 MAC           | `arp -a`                                                                       | 同網段下所有裝置 IP 對應 MAC                     |
| 查看路由表                 | `route print -4`                                                               | 流量走哪張網卡、哪個閘道                           |
| 追蹤經過的路由               | `tracert -d 8.8.8.8`                                                           | 封包經過哪些節點，`*` 不一定代表故障，如到DNS 走幾步         |
| 查看連線、監聽 Port、PID      | `netstat -ano\|findstr 443`                                                    | 哪些 Port 正在使用、由哪個程序使用                   |
| 測試 IP 是否可達            | `ping 192.168.8.1`<br>`ping 192.168.8.1 -t`                                    | 是否收到回應；沒回應也可能只是擋 ICMP                  |
| 測試 TCP Port           | `powershell Test-NetConnection 192.168.8.40 -Port 8443`                        | **PowerShell 執行**，看 `TcpTestSucceeded` |
| 查詢 DNS <br>(不能查hosts) | `nslookup <網址> <DNS IP>`<br>`nslookup pce.example.com`<br>                     | DNS 伺服器回覆哪個 IP；**不會查 hosts**           |
| 清除 DNS 快取             | `ipconfig /flushdns`                                                           | 修改 DNS 或 hosts 後可用                     |
| 查看hosts               | `type hosts`                                                                   |                                        |

`arp-a` ：查同網段所有裝置的MAC
![482](static/Pasted%20image%2020261107103858.png)

`route print -4`：查某個IP會到哪條
