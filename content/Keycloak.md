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


## LXC 方式安裝
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
# 注意：--http-enabled=true 是方便測試。生產環境建議 HTTPS Reverse Proxy (Nginx)
ExecStart=/opt/keycloak/bin/kc.sh start-dev --http-enabled=true --http-port=8080
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
自簽也要關掉
![](Pasted%20image%2020260706115337.png)



回到illumio 填三個框框，在SAML Identity Provider Certificate 加入Begin Certificate 跟 End Certificate 、Remote Login URL 、Logout Landing URL


![](Pasted%20image%2020260703152507.png)


✔ SSO 正常  
✔ 登入正常  

最後在illumio 加入Local Account 要有跟SAML一樣帳號才可以登入
Force Re-authentication：Yes
Sign SAML Request：Yes

## LDAP

![](Pasted%20image%2020260706162802.png)

![](Pasted%20image%2020260706162729.png)

| #   | 欄位名稱                    | 說明                                                                                                                             | 本篇輸入範例                                       |
| --- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------- |
| 1   | Console Display Name    | 本設定的名字                                                                                                                         | ldap                                         |
| 2   | Priority                | 當同一個Realm中有多個Provider時，Provider數字越小，表示越優先被使用                                                                                   | 0 (預設值)                                      |
| 3   | Import Users            | 若選”On”，Windows AD中的使用者會被同步至Keycloak的資料庫中                                                                                       | On (預設值)                                     |
| 4   | Edit Mode               | – READ_ONLY：從LDAP同步到Keycloak，在Keycloak不可更新數據  <br>– WRITABLE：Keycloak與LDAP雙向同步  <br>– UNSYNCED：從LDAP同步到Keycloak，在Keycloak可更新數據 | READ_ONLY (預設值)                              |
| 5   | Sync Registrations      | 若選”On”，LDAP新增的User會即時同步到Keycloak                                                                                               | OFF (預設值)                                    |
| 6   | Vendor                  | 提供目錄或認證的提供者                                                                                                                    | Active Directory                             |
| 7   | Username LDAP attribute | 所登入帳號的LDAP屬性，通常是cn或uid (這邊用sAMCount抓不到不知道為什麼)                                                                                  | cn (預設值)                                     |
| 8   | RDN LDAP attribute      | 對應到LDAP RDN屬性，通常是cn                                                                                                            | cn (預設值)                                     |
| 9   | UUID LDAP attribute     | 對應到LDAP UUID屬性，用於對應單一帳號，通常是objectGUID                                                                                          | objectGUID (預設值)                             |
| 10  | User Object Classes     | 指定User的屬性，通常是person, organizationalPerson, user                                                                                | person, organizationalPerson, user (預設值)     |
| 11  | Connection URL          | Windows AD (or LDAP)的網路位置，通常是ldap://開頭                                                                                         | ldap://{IP or hostname}                      |
| 12  | Users DN                | 指定某個節點向下的所有物件，通常會指定一個OU                                                                                                        | OU=jovepater,DC=jovepater,DC=tw              |
| 13  | Custom User LDAP Filter | 如果要過濾特別的屬性，可以在這個欄位指定                                                                                                           | 空                                            |
| 14  | Search Scope            | – One Level：只讀取Users DN同一層  <br>– Subtree：讀取Users DN向下所有階層                                                                     | Subtree                                      |
| 15  | Bind Type               | 指定Windows AD (or LDAP)驗證方式，simple表示使用帳號/密碼                                                                                     | simple                                       |
| 16  | Bind DN                 | 指定Windows AD (or LDAP)的驗證帳號                                                                                                    | CN=Administrator,CN=Users,DC=jovepater,DC=tw |
| 17  | Bind Credential         | Windows AD (or LDAP)驗證帳號的密碼                                                                                                    | ************                                 |

### Mapper
![](Pasted%20image%2020260706161635.png)

| #   | 欄位名稱                                 | 說明                      | 本篇輸入範例                         |
| --- | ------------------------------------ | ----------------------- | ------------------------------ |
| 1   | ID                                   | 唯一的序號                   | 由系統自動產生                        |
| 2   | Name                                 | 設定的名字，同一個Provider內不可重複  | email                          |
| 3   | Mapper Type                          | Mapper類別                | user-attribute-ldap-mapper     |
| 4   | User Model Attribute                 |                         | email                          |
| 5   | LDAP Attribute                       | ldap抓取欄位,這邊抓UPN登入電子郵件帳號 | UserPrincipalName              |


