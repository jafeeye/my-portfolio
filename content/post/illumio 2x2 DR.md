---
title: illumio 2x2 DR
toc: true
date: 2026-05-29
---
重新改FQDN，去刪除原本cert跟key `rm -rf /var/lib/illumio-pce/cert/server*`
再執行一次 illumio-pce-ctl setup --generate-cert




運作端：有四台機器
DR端：有四台機器(core,core,data0,data1)四台寫入hosts  `<IP> dr.hcc.com.tw`

1. 先寫入四台DR端的`/etc/hosts`,只寫入其中一台core當dr `<IP> dr.hcc.com.tw`

正常 illumio.gss.com.tw
DR 