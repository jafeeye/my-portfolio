---
title: Keycloak 搭配 illumio SAML 設定
toc: true
date: 2026-10-25
tags:
  - illumio
  - Keycloak
---
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



回到illumio 填三個框框，在SAML Identity Provider Certificate 加入Begin Certificate 跟 End Certificate 、Remote Login URL 、Logout Landing URL


![](Pasted%20image%2020260703152507.png)


✔ SSO 正常  
✔ 登入正常  

最後在illumio 加入Local Account 要有跟SAML一樣帳號才可以登入
Force Re-authentication：Yes
Sign SAML Request：Yes