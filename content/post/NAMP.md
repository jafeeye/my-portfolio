---
title: NAMP Web掃描工具
toc: true
date: 2026-10-17
tags:
  - 資安
  - 使用中工具
---
原文[出處](https://blog.hx99.net/Tech/4075.html)ㄐ及[源碼](https://gitee.com/cncsrf/nmap-scanner-web)作者在這，軟體使用 FastAPI完成，可以使用LXC部屬

###### 1、方式一：一键安装脚本（Ubuntu/Debian 推荐）

全自动安装 Python、nmap、依赖、生成密钥、注册 systemd 自启

```
git clone https://gitee.com/cncsrf/nmap-scanner-web.git
cd nmap-scanner-web
sudo bash install.sh
```


安裝完LXC ，可以執行以下
```
# 安装系统依赖
sudo apt install python3 python3-pip python3-venv nmap
# 拉取代码
git clone https://gitee.com/cncsrf/nmap-scanner-web.git
cd nmap-scanner-web
# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# 临时启动
python3 -m uvicorn main:app --host 0.0.0.0 --port 8090
```

登入密碼預設 admin/admin123
![](static/Pasted%20image%2020261017175252.png)
