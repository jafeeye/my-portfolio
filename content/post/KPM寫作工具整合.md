---
title: KPM寫作工具整合
toc: true
date: 2026-04-11
---

## Obsidian
要確定開啟目錄下有.obsidian資料夾，設定才會同步
- Dynamic Table of Content ：動態目錄外掛
- Embedded Code Title：程式碼檔名
- Remtely Save：同步OneDrive、WebDAV
- emo：自動將圖片上傳自Github
- Digram.net：畫流程圖好用軟體，向量編輯圖片(可用外部svg導入)正常情況下1pt=1px (macOS)，1pt=3/4px (Win)
- Commander：側邊欄按鈕隱藏
- Media Extened:嵌入Youtube等多媒體檔案
- cMenu
- Dataview
- Eagle
- PDF++
- S3agl：Eagle附件查看
- Timelines：編年史記
- Heatmap Calendar：热图，按年展示各习惯打卡情况
- AnyBlock
- Omnisearch
### 寫作大綱
**腳註 + 延伸閱讀 + 參考資料 + Backlink（反向連結）** 

### 寫作語法
- 插入本地圖片(正斜槓) `![顯示名稱](./)` 
- 轉譯運算符號(反斜槓)  `\` 
- 反向連結 `[[筆記名稱]]`  `[[筆記名稱#標題]]`  `[[筆記名稱|代替文本]]` 
  嵌入筆記內容  `![[筆記名稱#標題]]`  `![[筆記名稱^段落]`
- 插入引注連結 `[1](#^編號)` 或 `[[#^footnote|1]]`，步驟先打兩個`[`後打`^` 出現文章列表
- YAML前置資料區 (start)---  (end)--- 要在文件開頭才有效


**寫作示範1:**

>[!Note] 示例：修改文本颜色
>例如，可以创建一个名为 `snippet.css` 的文件并在其中加入以下代码。该片段可以将文本颜色更改为红色：
>```css
body {
  --text-normal: red;

>[!Note] Obsidian 如何处理删除的文件？
>这取决于你的设置。（要更改删除文件后的操作，请在 **设置 → 文件与链接** 下选择以下任一选项）：
>- **移至系统回收站**：默认情况下，删除的文件会进入你操作系统的系统回收站。要恢复文件，使用系统的文件管理器即可。
>- **移至软件回收站（.trash）文件夹**：Obsidian 将把删除的文件发送到仓库中的 `.trash` 文件夹。你可以在该文件夹中恢复这些文件。

**寫作示範2：**
- **移至系统回收站**：默认情况下，删除的文件会进入你操作系统的系统回收站。要恢复文件，使用系统的文件管理器即可。
- **移至软件回收站（.trash）文件夹**：Obsidian 将把删除的文件发送到仓库中的 `.trash` 文件夹。你可以在该文件夹中恢复这些文件。
- **永久删除**：文件会立即永久删除，无法恢复。

**寫作示範3:**
Obsidian支持以下文件格式：
1. Markdown 文件：`md`
2. 图像文件：`avif`、`bmp`、`gif`、`jpeg`、`jpg`、`png`、`svg`、`webp`
3. 音频文件：`flac`、`m4a`、`mp3`、`ogg`、`wav`、`webm`、`3g`

```toc

```


```dataview table 
time-played, length, rating from "games" sort rating desc 
```




## 雜項處理
可將Acrobat打開PDF文件中的向量文件圖物件，匯出SVG檔後導入
![gh|250](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1738729840000xgpna8.png)



## Memo
YT影片下載字幕，英文字幕直接轉成中文
![](Pasted%20image%2020260411101809.png)




### 延伸閱讀

1. [我的习惯追踪工作流 - 经验分享 - Obsidian 中文论坛](https://forum-zh.obsidian.md/t/topic/10506)
2. [Obsidian 中文帮助，裡面介紹許多OB的寫法](https://publish.obsidian.md/help-zh/%E7%BC%96%E8%BE%91%E4%B8%8E%E6%A0%BC%E5%BC%8F%E5%8C%96/%E6%A0%87%E7%AD%BE)
3. [[KPM管理研究]]
4. KPM學習交流網站，[PKMER](https://pkmer.cn/)