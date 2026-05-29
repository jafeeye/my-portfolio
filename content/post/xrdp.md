---
title: xrdp
toc: true
date: 2026-05-29
---



## 啟動腳本

去`/etc/xrdp/sesman.ini` 去找UserWindowManager、DefaultWindowManager，看這設定檔放在哪
```
UserWindowManager=Xclients 
DefaultWindowManager=Xclients
```

代表設定檔是放在startwm
```

sudo find / -name "*startwm*" 2>/dev/null
nano /usr/libexec/xrdp/startwm.sh
## 在裡面加入執行輸入法權限

```bash #!/bin/sh # 注入中文輸入法 
export GTK_IM_MODULE=ibus 
export QT_IM_MODULE=ibus 
export XMODIFIERS=@im=ibus 
/usr/bin/ibus-daemon -rxd & 
# 執行 Rocky Linux 預設的 X 會話 
if [ -r /etc/X11/xinit/Xclients ]; then 
. /etc/X11/xinit/Xclients 
else 
exec xterm 
fi

```


## 輸入法問題
無法打中文是因為使用者無法去執行ibus權限，指派成root就可以或是在一般使用者載入ibus環境



## 參考資料
- [WSL 2安装ubuntu-24.04踩坑日记（xrdp远程桌面、中文输入法、WSLg）](https://www.cnblogs.com/coolfan/articles/19085490 "发布于 2025-09-11 12:29") 
