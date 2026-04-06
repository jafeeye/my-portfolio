---
title: pichome 安裝
toc: true
date: 2026-04-06
---
1. 到Pichome的Github找compse檔
2. 因為最新3.0版有問題,所以到[docker hub](https://hub.docker.com/r/oaooa/pichome ) 指定tag 為 2.2.0，到 [Github](https://github.com/zyx0814/FilePress/releases) 使用2.2.0版下載`FilePress-2.2.0.zip`放到資料夾中
3. 編寫compose.yml

```
version: "3.8"

services:
  db:
    image: mariadb:10.7
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    ports:
      - 3307:3306
    volumes:
      - "./db:/var/lib/mysql"
    environment:
      - "TZ=Asia/Shanghai"
      - "MYSQL_ROOT_PASSWORD=root@admin.0001"
      - "MYSQL_DATABASE_FILE=/run/secrets/mysql_db"
      - "MYSQL_USER_FILE=/run/secrets/mysql_user"
      - "MYSQL_PASSWORD_FILE=/run/secrets/mysql_password"
    restart: always
    secrets:
      - mysql_db
      - mysql_password
      - mysql_user

  redis:
    image: redis:6.2-alpine
    restart: always
    ports:
      - 6379:6379
    environment:
      - TZ=Asia/Shanghai
  app:
    image: oaooa/pichome:2.2.0
    ports:
      - 8088:80
    links:
      - db
      - redis
    volumes:
      - "./site:/var/www/html"
      - "./ssl:/etc/nginx/ssl"
      - "/volume4/stock/eaglelib/stock.library:/mnt/libray"

    environment:
      - "MYSQL_SERVER=db"
      - "MYSQL_DATABASE_FILE=/run/secrets/mysql_db"
      - "MYSQL_USER_FILE=/run/secrets/mysql_user"
      - "MYSQL_PASSWORD_FILE=/run/secrets/mysql_password"
    restart: always
    secrets:
      - mysql_db
      - mysql_password
      - mysql_user

secrets:
  mysql_db:
    file: "./mysql_db.txt"
  mysql_password:
    file: "./mysql_password.txt"
  mysql_user:
    file: "./mysql_user.txt"
```

docker 的寫法是外映射內
maridb Port 3306(外):3306(內)
secret 的txt內容指定帳號及密碼
![[Pasted-img-20260406144630.png]]