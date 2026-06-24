---
title: illumio 2x2 DR
toc: true
date: 2026-05-29
---

重置illumio `sudo -u ilo-pce illumio-pce-ctl reset`
hosts
```
172.16.7.165 illumio-core0.bd1.dev 
172.16.7.165 illumio2x2.bd1.dev
172.16.7.161 illumio-core1.bd1.dev
172.16.7.159 illumio-data0.bd1.dev
172.16.7.115 illumio-data1.bd1.dev
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