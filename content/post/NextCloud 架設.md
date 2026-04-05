---
title: NextCloud 架設
toc: true
date: 2026-03-28
---

### 啟用外部儲存空間掛載
1. 創立資料夾
```bash
docker exec -it nextcloud bash
cd /var/www
mkdir file1
```
2. 在Container Manager映射正確資料夾，將Synology空間掛載至容器內file1，
![[Pasted image 20241031145738.png]]
3. 登入NextCloud後，先按右上角/應用程式/已停用應用程式,啟用External storage support ，然後在右上角/個人設定/外部儲存空間,掛載 `/var/www/file1` 資料夾  
![[Pasted image 20241031144701.png]]

4. 使用下面指令可以掃描nextcloud所有檔案系統 docker exec --user www-data nextcloud-app php occ files:scan -all


>[!Note] 重要
為避免系統的權限和檔案保護問題，target目錄盡量不要是NAS的共享根目錄，並授於適當的權限


### External sites

certbot產生SSL證書
### CODE 設定
```dokcer-compose
services:
  db:
    container_name: nextcloud-db
    image: mariadb:10.11
    restart: always
	command: >  
      --transaction-isolation=READ-COMMITTED  
      --binlog-format=ROW  
      --innodb-buffer-pool-size=512M  
      --innodb-log-file-size=128M  
      --innodb-flush-method=O_DIRECT  
      --innodb-flush-log-at-trx-commit=2  
      --max-connections=200
    volumes:
      - ./db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=c@25632
      - MYSQL_PASSWORD=c@25632
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
  redis:
    container_name: nextcloud-redis
    image: redis:alpine
    restart: always
    command: >  
      redis-server  
      --appendonly yes  
      --appendfsync everysec  
      --maxmemory 256mb  
      --maxmemory-policy allkeys-lru 
    volumes:
      - ./redis:/data
  app:
    container_name: nextcloud-app
    image: nextcloud
    restart: always
    ports:
      - 8081:80
    depends_on:
      - redis
      - db
    volumes:
      - ./nextcloud:/var/www/html
      - /volume4/data/:/var/www/file1
    environment:
      - MYSQL_PASSWORD=c@25632
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=db
      - REDIS_HOST=redis
  collabora:
    image: mietzen/synology-collabora:24.04.9.1.1
    container_name: collabora-app
    restart: always
    ports:
      - 9980:9980
    environment:
      extra_params: "--o:security.seccomp=false --o:security.capabilities=false --o:ssl.enable=false --o:ssl.termination=false" 
      DONT_GEN_SSL_CERT: 1
      username: admin 
      password: admin
    # 群輝CODE會有seccomp權限問題，不僅要選擇適合docker容器，還要參數進行false
    # 設定password 與username 為本可以進入CODE管理員面板，網址 http://NASIP:9980/browser/dist/admin/admin.html
    # ssl.enable 因為 ssl 放在 nginx 那邊所以要避免他嘗試著開啟 https 伺服器，而且下一行也會禁止他產生憑證，不關閉會錯誤
    # ssl.termination 因為前面關閉 https 但是我們前面實際上存取還是用 nginx 的 https, 所以要設定這項讓他不會擅自轉址成 http，而被混合內容政策擋掉
    # net.web_root 如果要把它塞在子路徑底下，路徑寫這邊
    # 這個是避免他產生自簽 ssl 憑證，搭配上述的 ssl.enable 可以完全關閉他的 ssl 功能
volumes:
  nextcloud:
  db:
```


>[!Note] 重要
>如果要用外部文件檔案WOPI，可以使用OnlyOffice，OXOOL不能在群暉Container Manager 使用會出錯
>無法播放MKV與MP4檔案，可能是瀏覽器不支援H.265編碼，Chrome目前支援


### 方法 2 - 使用PVE Script
1. 使用Nextcloud 腳本 (VM)
2. 按照部分下一步
![](20260405-nc1.png)
3. 按照步驟下一步
![](20260405-nc2.png)
4. 按照步驟下一步
![](20260405-nc3.png)
5. 按照步驟下一步
![](20260405-nc4.png)



### 參考資料
1. 【TrueNAS 24.04】公网IPv6+OpenWrt+Nextcloud+Collabora+NPM实现Office在线协同编辑（HTTPS公网版）
2. 【TrueNAS 24.04】Collabora Online 添加自定义字体（font）
3. 架設Nextcloud個人雲端硬碟 ＋ 網頁版LibreOffice教學 (docker-compose + ZeroTier內網穿透),參考網址:https://ivonblog.com/posts/nextcloud-docker/
4. 群晖Docker中的Nextcloud挂载任意本地存储,參考網址:https://zhaodsm.de/archives/382.html