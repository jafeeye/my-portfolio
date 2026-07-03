---
title: keycloak
toc: true
date: 2026-07-03
---

1. 使用Docker 安裝
```
# 更新系統套件 
sudo dnf update -y 
# 新增 Docker 官方套件庫 sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
# 安裝 Docker 引擎 
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y 
# 啟動 Docker 並設定開機自動啟動 
sudo systemctl start docker sudo systemctl enable docker
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

![](Pasted%20image%2020260703143859.png)


4. 分別填入下面資訊
Issuer URL= Keycloak Client ID
https://illumio-kevin.bd1.dev:8443/login
Assertion Consumer URL (ACS)= Keycloak Valid Redirect URIs
https://illumio-kevin.bd1.dev:8443/login/acs/a1183a40...
Master SAML Processing URL
https://illumio-kevin.bd1.dev:8443/login/acs/a1183a40...

![](Pasted%20image%2020260703145756.png)

![](Pasted%20image%2020260703145531.png)

![](Pasted%20image%2020260703145928.png)

![](Pasted%20image%2020260703150337.png)

要新增一個Mapper 對應 `NameID Format urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress`
![](Pasted%20image%2020260703150721.png)

![](Pasted%20image%2020260703150824.png)


![](Pasted%20image%2020260703152209.png)


![](Pasted%20image%2020260703152246.png)
回到illumio 填三個框框，在SAML Identity Provider Certificate 加入Begin Certificate 跟 End Certificate 、Remote Login URL 、Logout Landing URL


![](Pasted%20image%2020260703152507.png)


✔ SSO 正常  
✔ 登入正常  
❌ logout 沒做 SLO