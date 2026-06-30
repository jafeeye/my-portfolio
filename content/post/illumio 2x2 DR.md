---
title: illumio 2x2 DR
toc: true
date: 2026-05-29
---
## 重裝illumio 
1. 重置資料庫重新設定
`sudo -u ilo-pce illumio-pce-ctl reset`

2. 4台電腦分別寫入 hosts,給主要那台core FQDN別名 (hosts可用scp複製)
```
172.16.7.106 illumio-core0.bd1.dev
172.16.7.106 illumio2x2.bd1.dev
172.16.8.85 illumio-core1.bd1.dev
172.16.8.112 illumio-data0.bd1.dev
172.16.8.124 illumio-data1.bd1.dev
```



/etc/illumio-pce/runtime-env.yml
```
# Configuration generated 05/19/2025 15:01:36+0800
install_root: "/opt/illumio-pce"
runtime_data_root: "/var/lib/illumio-pce/runtime"
persistent_data_root: "/var/lib/illumio-pce/data"
ephemeral_data_root: "/var/lib/illumio-pce/tmp"
log_dir: "/var/log/illumio-pce"
private_key_cache_dir: "/var/lib/illumio-pce/keys"
pce_fqdn: illumio2x2.bd1.dev
service_discovery_fqdn: 172.16.7.165
cluster_public_ips:
  cluster_fqdn:
  - 172.16.7.165
  - 172.16.7.161
node_type: core
cluster_type: 4node_v0_small
web_service_private_key: "/var/lib/illumio-pce/cert/server.key"
web_service_certificate: "/var/lib/illumio-pce/cert/server.crt"
trusted_ca_bundle: "/etc/ssl/certs/ca-bundle.crt"
email_address: illumio_isbd1@gss.com.tw
service_discovery_encryption_key: OpuZq6/BuV0LviCoriHNDuW8Y6hrEz6gZoOB0nnS7iU=
smtp_relay_address: ms1.gss.com.tw:25
active_standby_replication:
  active_pce_fqdn: illumio2x2.bd1.dev
```

要複製key跟crt 同時過去才可以
scp 複製過去會有root 權限修改為檔案擁有者,所以會沒辦法讀
```
chown root:ilo-pce /etc/illumio-pce/runtime_env.yml
chmod 640 /etc/illumio-pce/runtime_env.yml
```
改憑證資料夾權限
```
# 1. 把整個憑證資料夾的擁有者改為 root，群組改為 ilo-pce
chown -R root:ilo-pce /var/lib/illumio-pce/cert
# 2. 設定資料夾權限，讓 ilo-pce 群組可以進得去
chmod 750 /var/lib/illumio-pce/cert
# 3. 設定憑證權限 (root可讀寫，ilo-pce可讀)
chmod 640 /var/lib/illumio-pce/cert/server.crt
# 4. 設定私鑰權限 (極度機密：root可讀寫，ilo-pce可讀，其他人完全不能看)
chmod 640 /var/lib/illumio-pce/cert/server.key
```








重新改FQDN，去刪除原本cert跟key `rm -rf /var/lib/illumio-pce/cert/server*`
基本上在執行sudo  illumio-pce-ctl setup --generate-cert ,最主要會產出server.key 跟server.key,並且腳本會產出ilo-pce這個使用者,並且把這兩個檔案擁有者權限改成ilo-pce

憑證檢查指令
```
illumio-pce-env setup --test 5 --list
```







運作端：有四台機器
DR端：有四台機器(core,core,data0,data1)四台寫入hosts  `<IP> dr.hcc.com.tw`

1. 先寫入四台DR端的`/etc/hosts`,只寫入其中一台core當dr `<IP> dr.hcc.com.tw`

正常 illumio.gss.com.tw
DR 




/var/lib/illumio-pce 跟 /var/lib/illumio-pvr/cert 下的擁有者都是root
```
# 1. 把 illumio-pce 目錄（不包含底下所有子檔案）的 Owner 改為 root
sudo chown root:ilo-pce /var/lib/illumio-pce

# 2. 把 cert 目錄的 Owner 改為 root
sudo chown root:ilo-pce /var/lib/illumio-pce/cert
```

重新執行腳本出現 `Error: Unable to verify certificate chain.` 要把
```

trusted_ca_bundle: "/var/lib/illumio-pce/cert/server.crt"
```
憑證檢查
```
illumio-pce-env setup --test 5 --list
```


## 移除illumio
In order to completely uninstall and remove the PCE for your system, perform the following steps:
1. Remove the PCE UI package:
    `rpm -e illumio-pce-ui`
2. Remove the main PCE package:
    `rpm -e illumio-pce`
3. Manually delete these directories:
```
/var/lib/illumio-pce
/var/log/illumio-pce
/etc/illumio-pce
```


## 憑證重新識別
用 `/opt/illumio-pce/illumio-pce-env setup --generate-cert` 重產憑證容易出現問題，因為會沒把憑證放入bundle-CA

```
## 移除 server.crt，並更新
rm -f /etc/pki/ca-trust/source/anchors/server.crt
update-ca-trust extract
## 查詢憑證鏈,確認在CA bundle有沒有刪除illumio自簽CA
trust list
# 用setup -generate-cert產出新憑證在更新一次
update-ca-trust extract
```

Linux 的憑證管理分為兩條路線：
1. **檔案派（File-based）：** 把檔案丟進 `/etc/pki/ca-trust/source/anchors/`，再跑 `update-ca-trust`。
2. **資料庫派（Database-based）：** 使用 `trust anchor --store` / `--remove`。
因為 **Illumio 官方文件建議的做法是標準的「檔案派」**（直接在 `pce_runtime.yml` 指定純文字的 `ca-bundle.crt` 路徑），所以你只需要用 `rm` 檔案 + `update-ca-trust extract` 就能完美控管。如果你用資料庫派的 `--remove` 去砍系統內建的官方憑證（就會出現 read-only 錯誤）