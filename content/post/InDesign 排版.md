---
title: InDesign Affinity 排版
toc: true
date: 2026-04-25
---

PDF 貼魔王：將多頁PDF快速貼入ID工具
常用：
底部壓個色塊（放在最後）
出血都是3mm
文字/複合字體 
字形搭配中英混合襯線字體 中英混合非襯線
正常排版強調字元是用`粗黑體`，除非是財務報表、國外翻譯、小說
在排版書籍括弧實現方式為 **`表格+手工括弧`** 通常用心智圖軟體呈現在輸出
![](Pasted%20image%2020260621201851.png)

![gh](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1742655189000gd6yi3.png)


Word 要做出血方法是在紙張大小各加上3mm
21.6 
Word 讀入項目符號一開始設定明體+Times符合字體就會檢少排版錯亂問他
Word VBA 製作參考線方法

#列印模板 #模板 


## ID 置入多頁PDF
*(可考慮非官方腳本Cooldtp，快速置入多頁PDF)

*Illustrator CC v2018.3：新增多頁PDF置入功能

Step.1 新建一個空白圖層，並將圖層1鎖定(圖層2放置匯入的PDF)
![](Pasted%20image%2020260621201611.png)
Step.2 按下Ctrl+Alt+F11出現指令碼視窗，點選Sample資料夾/PlaceMultiPagePDF.jsx
Step.3 打開pdf出現Choose a Document 視窗，選擇目前indd專案(ex.未命名-1.indd)，然後出現 Choose a Page 視窗，為選擇indd專案第幾頁開始置入，選擇完成後開始置入。
Step.4 置入完成後，須調整置入多頁跑掉的PDF版面邊界，先建立一個空白對象樣式(對象樣式1)
![](Pasted%20image%2020260621201628.png)
Step 5. Ctrl+F出現尋找更改視窗，將圖層2套入剛才新建對象樣式按確定。
![](Pasted%20image%2020260621201707.png)
Step.6 按版面/邊界和欄，檢視文件邊界大小。
![](Pasted%20image%2020260621201719.png)
Step.7 在對象樣式中，設定文件邊界、版芯。
![](Pasted%20image%2020260621201805.png)
Step 8.若要裁減匯入PDF的頁碼，在裁切量調整。
![](Pasted%20image%2020260621201825.png)
## ID 製作書背封面
1. 首先開啟新文件，先輸入主要頁面大小，並且記得取消勾選「對頁」功能，然後按下「邊界和欄」來設定上下邊界，這裡有個關鍵是要把邊界都設定為零。
![](Pasted%20image%2020260621184509.png)
2. 在「頁面」面板中，按下主版頁面「A-主版」圖示，按右鍵將「允許移動文件頁面」取消選擇，再接著按右鍵選擇「新增主版」。
![](Pasted%20image%2020260621184538.png)
3. 我們要新增書背用的主版頁面，名稱設定為“書背”，寬度設定為16.6公釐（依實際情形設定）。設定完成後就可以在主版頁面上看到細長的主版圖示。
![](Pasted%20image%2020260621184610.png)
4. 同樣的方式再來新增一個折頁用的主版頁面，名稱設定為“折頁”
![](Pasted%20image%2020260621192747.png)
5. 接下來我們到一般頁面上，先新增一個頁面，然後將「B-書背」的主版套用到這個新頁面上，會出警告視窗，請按下「使用主版頁面大小」，接下來把新頁面拖曳到第1頁的右邊來產生跨頁，這樣就先完成封面（其實是封底）與書背的跨頁合成。
利用「建立新頁面」按鈕來新增頁面，拖曳「B-書背」主版到頁面上
![](Pasted%20image%2020260621192849.png)
按下「使用主版頁面大小」，將更換主版的頁面拖曳到第1頁的右邊來產生跨頁，請注意滑鼠游標的圖示要跟上圖一樣才會產生跨頁，初步完成封面與書背的跨頁合成
![](Pasted%20image%2020260621193223.png)

6. 依照前一步驟的方式，新增一個頁面並套用上「A-主版」，然後將新頁面移到[1-2]頁的右邊來形成跨頁。
![](Pasted%20image%2020260621193406.png)
7. 同樣依照前一步驟的方式，新增一個頁面並套用上「C-折頁」，然後將新頁面移到[1-3]頁的左邊來形成跨頁。
![](Pasted%20image%2020260621193417.png)
8. 最後再新增一個頁面，然後將新頁面移到[1-4]頁的右邊來形成跨頁。如此，封面的主要結構就完成了
![](Pasted%20image%2020260621193426.png)
![](Pasted%20image%2020260621193458.png)
![](Pasted%20image%2020260621193508.png)


9. 完成後輸出怎麼辦？當然很簡單啦，只要在輸出選項中，勾選「跨頁」
![](Pasted%20image%2020260621193523.png)
10. 完成後的封面PDF就會有出血、裁切⋯⋯等等印刷用標記，就連書背與折頁的折線也會標示出來喔
![](Pasted%20image%2020260621193530.png)









## Affinity
![gh](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1753278034000mncu7k.png)



## 列印模板

模板下載
[套印檔下載 證件/底紋邊框 - 鶴屋｜金鶴購](https://www.herwood.com.tw/download/category/visiting_cards_credentials)
[刀模版型下載藍格印刷](https://ec.blueco.com.tw/Mold)
建立刀模[立牌AI檔案](https://youtu.be/3zvJOj8D6G0?si=SxpSN5-C2YdRO_Ey)
[建立文字外框](https://youtube.com/shorts/L4A4o4ZstQE?si=y7B-2MsadVEFcqrY)


Inkscape 繪圖
[inkscape科研绘图大神之路-基础教程50讲](https://b23.tv/j02yuEG)