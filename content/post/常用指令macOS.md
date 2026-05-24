---
title: macOS 常用設定指令
toc: true
date: 2026-04-02
---
macOS 家目錄 `/user/使用者名稱`


| 系統    | 目錄    | 用途說明                        |
| ----- | ----- | --------------------------- |
| macOS | /home | 純粹掛載目錄,如果Linux使用zfs格式也會當掛載點 |



| 功能                | 快速鍵                     |
| ----------------- | ----------------------- |
| 擷取整個螢幕儲存至桌面       | Shift + Cmd + 3         |
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
- Option`+`Command`+`Esc` 關閉程式





修復損毀應用程式
sudo spctl --master-disable

移除macOS 的 Gatekeeper
`xattr -d com.apple.quarantine /Applications/WindTerm.app`



## 輸入法
macOS鍵盤與Win鍵盤頓號位置不一樣
頓號（、）：直接按鍵盤的頓號鈕
句號（。）：Shift + ㄡ
逗號（，）：Shift + ㄝ
問號（？）：Shift + ㄥ
注音輸入法下中文模式冒號為大寫 (Shift+:)
英文輸入法只能打出半形
中文輸入法只能打出全形，包括全形英文、標點符號
＊如果要打出鍵盤一個按鈕的不同符號，可以打了之後再按空白就可選擇其他
![gh|500](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1738763534000azokno.png)
打方向鍵符號，使用使用者辭典功能
![gh|400](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1738757970000qujvvy.png)
設定關閉SIP
M2：按住開機鍵直到出現選項，在「復原」App 中，選擇「工具程式」>「開機安全性工具程式」
![gh|350](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/17415223560007xzd2f.png)

## Command line
`open -a 應用名.app` 開啟應用程式
`open .`  開啟當前目錄