---
title: SSO
toc: true
date: 2026-07-03
---
方案比較

| **軟體名稱**            | **屬性**           | **SAML 能力** | **內建統一 Dashboard 門戶** | **適用場景**                |
| ------------------- | ---------------- | ----------- | --------------------- | ----------------------- |
| **authentik**       | 開源 (Self-Hosted) | 強，設定直覺      | **優異**，現代化卡片式介面       | 中小型企業、私有雲、技術團隊維運        |
| **Keycloak**        | 開源 (Self-Hosted) | 極強，標準架構     | 偏向帳戶管理，需客製 Theme      | 大型開源專案、需要複雜多租戶架構        |
| **ZITADEL**         | 開源/商業雙軌          | 完整支援        | 有，簡潔的 Workspace 介面    | B2B SaaS 開發商、雲原生架構需求    |
| **Okta / Entra ID** | 商業 SaaS          | 工業標準級       | **頂級**，支援分類、搜尋與推播     | 不想維護基礎設施、有法遵與資安高合規需求的企業 |
| Authelia            |                  |             |                       |                         |
| Microsoft ADFS      |                  |             |                       |                         |

## Authentik

rer [err](./Rclone.MD)


### LDAP

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

