---
title: macOS 常用設定指令
toc: true
date: 2026-04-02
---
macOS 家目錄 `/user/使用者名稱`


| 系統    | 目錄    | 用途說明                        |
| ----- | ----- | --------------------------- |
| macOS | /home | 純粹掛載目錄,如果Linux使用zfs格式也會當掛載點 |



| 擷取整個螢幕儲存至桌面       | Shift + Cmd + 3         |
| ----------------- | ----------------------- |
| 截圖選擇區域儲存至桌面       | Shift + Cmd + 4         |
| 截圖選擇區域儲存至剪貼簿      | Shift + Cmd + 4，再按下Ctrl |
| 顯示隱藏檔案            | Shift + Cmd + .         |
| 顯示截圖工具            | Shift + Cmd + 5         |
| 開啟「下載」資料夾         | Cmd + Opt + L           |
| 在 Finder 中開啟桌面資料夾 | Cmd + Shift + D         |
| 新增資料夾             | Cmd + Shift + N         |
| 丟至垃圾桶             | Cmd + Delete            |
| 重命名               | Return                  |
| 顯示特殊符號(注音模式下中文)   | Opt+Shift+B             |
| Finder到指定資料夾      | Cmd + Shift + G         |


常用快速鍵  
- Option+Cmd+drag make alias
- Cmd+Shift+. hide/show file
- Cmd+Option+D hide dock
- fn+control+方向 halve window
- Shift+Cmd+4
- Shift+Cmd+Ctrl+4 copy image
- 中文輸入法反引號 Option+~
- 勿擾模式 F6
- Ctrl+Cmd+Space emoji keyboard



移除macOS 的 Gatekeeper
`xattr -d com.apple.quarantine /Applications/WindTerm.app`


## Command line
`open -a 應用名.app` 開啟應用程式
`open .`  開啟當前目錄