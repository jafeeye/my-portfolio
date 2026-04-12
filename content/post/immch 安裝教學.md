---
title: immich 安裝教學
toc: true
date: 2026-04-06
---
## Synology DSM

1. 下載docker-compose.yml及example.env
2. 編輯檔案
.env
```
UPLOAD_LOCATION=/volume4/photo/library
DB_DATA_LOCATION=./postgres
IMMICH_VERSION=v2
DB_PASSWORD=postgres
DB_USERNAME=postgres
DB_DATABASE_NAME=immich
```

建立不同使用者,並且套用儲存範本資料夾會被放在
```
/library/admin

```
