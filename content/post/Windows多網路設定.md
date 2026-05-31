---
title: Windows多網路設定
toc: true
date: 2026-05-28
---
## VMware Workstation




## HyperV+VMware 導致VMNAT無法使用
因為Hyper-V搶了NAT某個網段，以致VMware雖然有設定但是錯誤
![](Pasted%20image%2020260531143804.png)
去VMNet8的網卡確認有被指定網關
![](Pasted%20image%2020260531143627.png)


## 網路卡橋接
橋接的原理是把兩張網卡弄成一張，在這邊是建立橋接器之後，兩張卡都不能單獨設定IP，到橋接器去設定一個區網IP，tap網卡在虛擬機同網段就能上網
![](Pasted%20image%2020260531191753.png)



## 參考資料
- [HackMD，VM NAT內網穿透紀錄總結](https://hackmd.io/@Yusawa/SkukwDEEC)
