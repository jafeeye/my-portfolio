---
title: Keycloak 搭配 illumio SAML 設定
toc: true
date: 2026-10-25
tags:
  - illumio
  - Keycloak
---
```toc
```
### 一、安裝方式
安裝方式可使用LXC或Docker安裝
- LXC 方式
```
# 1.更新套件清單並升級 
apt update && apt upgrade -y 
# 安裝 OpenJDK 17 與常用工具（如 wget 和 unzip） 
apt install default-jdk -y wget unzip curl -y

## 2.下載keycloak
# 切換到 /opt 目錄
cd /opt
# 建議至官網確認最新版本號，此處以 24.0.0 為範例
wget https://github.com/keycloak/keycloak/releases/download/24.0.0/keycloak-24.0.0.tar.gz
# 解壓縮
tar -xvzf keycloak-24.0.0.tar.gz
# 重新命名資料夾方便後續維護
mv keycloak-24.0.0 keycloak
# 刪除壓縮檔
rm keycloak-24.0.0.tar.gz

## 3.建立keycloak專屬使用者
# 建立一個名為 keycloak 的系統使用者，且不允許直接登入
useradd -r -m -U -d /opt/keycloak -s /bin/false keycloak
# 將 Keycloak 目錄的擁有者改為該使用者
chown -R keycloak:keycloak /opt/keycloak

## 4.設定keycloak管理員密碼
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=你的安全密碼

## 5.建立systemd服務，存檔
nano /etc/systemd/system/keycloak.service

[Unit]
Description=Keycloak Identity and Access Management
After=network.target

[Service]
User=keycloak
Group=keycloak
Environment=KEYCLOAK_ADMIN=admin
Environment=KEYCLOAK_ADMIN_PASSWORD=你的安全密碼
#注意：--http-enabled=true 是方便測試。生產環境建議 HTTPS Reverse Proxy (Nginx)
ExecStart=/opt/keycloak/bin/kc.sh start-dev --http-enabled=true --http-host=0.0.0.0 --http-port=8080
WorkingDirectory=/opt/keycloak
Restart=always

[Install]
WantedBy=multi-user.target

#6. 建立keycloak 服務
# 重新載入 systemd 設定
systemctl daemon-reload

# 啟用並啟動 Keycloak 服務
systemctl enable keycloak
systemctl start keycloak
```
- Docker 設定方式

1. 使用Docker 安裝
```
# 更新系統套件 
sudo dnf update -y 
# 新增 Docker 官方套件庫 
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
# 安裝 Docker 引擎 
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y 
# 啟動 Docker 並設定開機自動啟動 
sudo systemctl start docker && sudo systemctl enable docker
# 建立一個目錄
mkdir ~/keycloak && cd ~/keycloak
# 建立yaml
nano docker-compose.yml
```

```
version: '3.8'

services:
  postgres:
    image: postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: password123 # 請修改為更強的密碼
    ports:
      - "5432:5432"

  keycloak:
    image: quay.io/keycloak/keycloak:latest
    command: start-dev
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: password123 # 必須與上面 postgres 的密碼相同
      KEYCLOAK_ADMIN: admin       # Keycloak 管理員帳號
      KEYCLOAK_ADMIN_PASSWORD: admin_password # Keycloak 管理員密碼
    ports:
      - "8080:8080"
    depends_on:
      - postgres

volumes:
  postgres_data:
```
2. 執行 docker compose
```
sudo docker compose up -d
```
3. 防火牆開啟
```
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

- 更改原本預先設定Port
```
nano /opt/keycloak/conf/keycloak.conf
# 更改 HTTP 的監聽 Port (預設是 8080)
http-port=8080
# 更改 HTTPS 的監聽 Port (預設是 8443) 
https-port=8443

/opt/keycloak/bin/kc.sh build 
systemctl restart keycloak
```


### 二、設定方式
1. 先登入http://IP:8085 先建立初始realm
![](static/Pasted%20image%2020261025172321.png)

2. 會創立illumio的realm
![](Pasted%20image%2020260703143859.png)

3. 回去illumio SAML 設定頁面，記錄住設定資訊
Issuer URL= Keycloak Client ID
https://illumio-kevin.bd1.dev:8443/login
Assertion Consumer URL (ACS)= Keycloak Valid Redirect URIs
https://illumio-kevin.bd1.dev:8443/login/acs/a1183a40...
Master SAML Processing URL
https://illumio-kevin.bd1.dev:8443/login/acs/a1183a40...
![](static/Pasted%20image%2020261025203401.png)


4. 回去Keycloak 設定，點選Create Client，填入Issuer URL
![](static/Pasted%20image%2020261025172827.png)
5. 創立之後先按儲存
![](static/Pasted%20image%2020261025174617.png)
6. 進去修改詳細設定值
![](Pasted%20image%2020260703145531.png)

![](Pasted%20image%2020260703145928.png)

![](Pasted%20image%2020260703150337.png)

要新增一個Mapper 對應 `NameID Format urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress`
![](Pasted%20image%2020260703150721.png)

創立一個`User Property` 的Mapper
![](Pasted%20image%2020260703150824.png)


![](Pasted%20image%2020260703152209.png)


![](Pasted%20image%2020260703152246.png)
自簽也要關掉
![](Pasted%20image%2020260706115337.png)

注意回到illumio畫面回填三個框，在SAML Identity Provider Certificate 加入Begin Certificate 跟 End Certificate ，、Remote Login URL 及 Logout Landing URL 網址，記得URL後面不能用斜線不然不能順利跳轉


![](Pasted%20image%2020260703152507.png)


✔ SSO 正常  
✔ 登入正常  

最後在illumio 加入Local Account 要有跟SAML一樣帳號才可以登入
Force Re-authentication：Yes
Sign SAML Request：Yes