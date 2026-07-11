---
title: phpIPAM
toc: true
date: 2026-07-11
---
1. 關閉基礎設定
```
# 關閉 SELinux (重啟後永久生效，或編輯 /etc/selinux/config)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

# 開放防火牆 HTTP 服務
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

2. 安裝Apache與MariaDB
```
# 安裝 Apache 與 MariaDB
sudo dnf install -y httpd mariadb-server mariadb git

# 啟動並設定開機自啟
sudo systemctl enable --now httpd mariadb

# 初始化 MariaDB 安全設定 (依提示設定 root 密碼、始化過程都採取用預設值只要一直按下 Enter 鍵即可)
sudo mysql_secure_installation
```

3. 安裝php 相關套件
```
# 安裝 PHP 及其擴充模組
sudo dnf install -y php php-cli php-fpm php-mysqlnd php-gd php-common php-ldap php-pdo php-pear php-snmp php-xml php-mbstring php-gmp php-json

# 啟動並設定 PHP-FPM 開機自啟
sudo systemctl enable --now php-fpm

# 修改 php.ini 設定時區 (避免系統時間報錯)
# 尋找 ;date.timezone = 改為：
sudo sed -i 's/;date.timezone =/date.timezone = Asia\/Taipei/' /etc/php.ini
```

4. 下載phpipam並設定讀寫權限
```
# 下載最新穩定版 phpIPAM 到 /var/www/html
cd /var/www/html
sudo git clone --recursive https://github.com/phpipam/phpipam.git .

# 複製並建立設定檔
sudo cp config.dist.php config.php

# 修改設定檔中的資料庫連線資訊 (這邊把dbname跟username都設成phpipam)
nano /var/www/html/config.php
$db['host'] = 'localhost';
$db['user'] = 'phpipam';
$db['pass'] = '想一組資料庫密碼';
$db['name'] = 'phpipam';
$db['port'] = 3306;

# 修正目錄權限，讓 Apache (httpd) 有權限讀寫
sudo chown apache:apache /var/www/html
```

5. 編輯 Apache 主設定檔 `/etc/httpd/conf/httpd.conf`，找到 `<Directory "/var/www/html">` 區塊，將 `AllowOverride None` 修改all，並重啟服務httpd php-fpm
```
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

sudo systemctl restart httpd php-fpm
```

6. 因為發現網頁 `http://IP/index.php?page=install` 創空資料庫自動安裝會有問題，所以先不登入網頁，先使用指令創db，並匯入程式官方db的SCHEMA
```
# 先用root 登入MariaDB，進入MariaDB指令結尾都是分號
sudo mysql -u root

# 1. 建立 phpipam db檔案
CREATE DATABASE phpipam;

# 2. 建立db使用者及密碼，帳密要跟前面config.php一致
CREATE USER 'phpipam'@'localhost' IDENTIFIED BY '想一組資料庫密碼';

# 3. 將 phpipam 資料庫的所有權限賦予該使用者
GRANT ALL PRIVILEGES ON phpipam.* TO 'phpipam'@'localhost';

# 4. 重新整理權限並離開
FLUSH PRIVILEGES;
EXIT;
# 5. 匯入官方db SCHEMA
mysql -u root -p phpipam < /var/www/html/db/SCHEMA.sql
```

7. 進入網頁 `http://IP/index.php`，SCHEMA.sql預設登入帳密 admin/ipamadmin



## homelable
http://IP:3000