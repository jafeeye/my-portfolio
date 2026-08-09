---
title: mDNS
toc: true
date: 2026-08-08
---
Avahi是一个免费的零配置网络（zeroconf）实现，包括一个用于组播DNS/DNS-SD服务发现的系统。它允许程序发布和发现在本地网络上运行的服务和主机.而无需特定配置。例如.traefik.local homepage.local`
## 安装Avahi
Ubuntu /Debian
$ sudo apt install avahi-daemon avahi-utils
CentoS
$ sudo yum installnss-mdns avahi avahi-tools

如果提示nss-mdns找不到，就安装一下epel源
开启服务
systemctl restart avahi-daemon.service

## Docker
```
avahi-helper:
#这个容器会将以.Local结尾的Host广播出去
#在同一个同一个局域网的用户就都能访问到了
  image:hardillb/traefik-avahi-helper:latest
  restart: unless-stopped
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /run/dbus/system_bus_socket:/run/dbus/system_bus_socket
  networks:
    - web-network
```


## mDNS Reflector


## mDNS-Bridge
將mDNS 轉給 DNS Server