---
title: cookpti
toc: true
date: 2026-05-26
---

更新系统并安装组件
```
## 記得先更新，不然裝完大套件因為OpenSSL系統直接炸
dnf update -y
## 安裝虛擬化套件
dnf install cockpit-machines libvirt qemu-kvm virt-install virt-viewer
dnf install -y wget lrzsz net-tools
```
啟動服務
```
## 啟用服務
systemctl enable --now libvirtd
## 確認服務是否正常運作
systemctl status libvirtd
systemctl status cockpit.socket
```


允许 Cockpit 使用 root 登录**
echo "#root" | tee /etc/cockpit/disallowed-users

**4. 开放防火墙端口（默认无需操作）**

> firewall-cmd --add-port=9090/tcp --permanent
> 
> firewall-cmd --reload





## 參考資料
- [甚麼值得買，KVM虚拟化平台搭建与Cockpit管理：基于Rocky Linux 9.6](https://post.smzdm.com/p/apw3dwl0/)
- 