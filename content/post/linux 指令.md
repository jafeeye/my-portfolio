---
title: 常用Linux指令
toc: true
date: 2026-04-02
---
macOS 要push之前驗證裝 `brew tap microsoft/git-credential-manager`
## 啟用zsh
```
nano ~/.zshrc        //   ~/代表家目錄
```
加入以下內容
```
# 初始化補齊系統 
autoload -Uz compinit compinit 
# 開啟選單模式，按下 Tab 兩次後進入選單 
zstyle ':completion:*' menu select
```
存檔
```
source ~/.zshrc      //   重新讀取設定檔
```
要快速顯示檔案輸入cd，tab兩次出現資料夾，再按tab做選擇

## 網路

`ifreload -a` debian 設定網路重新載入設定
