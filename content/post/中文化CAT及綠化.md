- 相關軟體
- 中文化精靈 ChiWizard
- 資源編輯 ResEdit
- 資源編輯 Resource Hunter
- Alchemy Catalyst 2021
	- 有人做出2023繁中 https://apk.tw/forum.php?mod=viewthread&tid=1043159&extra=page%3D1&mobile=2
- Passolo
- LocalizeRC
- Fontfly、FontSetter
- HexWorkshop 4.23繁體中文版
- Zeta Resource Editor：編輯 .NET 資源
- Glossary 完美中文化字典產生器從 2.0 版開始改名為 ChiWizard
- Ini Translator 可以用來簡化 INI 類型檔案翻譯工作的工具
- TransText https://github.com/Yonsm/TransText
 -  Fantasy Editor Lite：字典檔轉換
 - ResScope
 - Visual Locailize
 - CXE_read
 - codefusion:製作補丁工具：https://dotblogs.azurewebsites.net/larrynung/2011/01/27/21069
 - PASS Resource Finder:找標準資源定位
- ResScope VER 1.94 - 极强的软件资源分析和编辑工具  [软件简介]
- freeRes VER 0.94 - 分析软件压缩资源的超级利器，能够重建可编辑资源   [软件简介]
- HexEditor VER 0.20 - 针对汉化用的十六进制编辑工具   [软件简介]
- GetVBRes VER 0.90 - 针对 VB 程序的汉化工具   [软件简介]
- GetStrRes VER 0.51 - 针对 Delphi 程序非标准资源字符串的汉化工具 
- WinASCII
- HecCMP
#### 翻譯NET資源[[#^eeaec2|2]]
.NET 資源要用 Radialix 3 軟體翻譯然後搭配 DotNetHelper V2.2 反組譯和組譯來完成。  
至於Sisulizer好像必需把.net SDK 4.7.1 的 al.exe al.exe.config  複製到C:\Windows\Microsoft.NET\Framework\v4.0.30319裡面
SDL Passol 可以翻譯 .NET 資源，但是目標語言記得選 .NET繁體，才抓的到資源  
.NET SDK 你可以依照你需要的版本下載吧？  
Sisulizer 4 通常提醒需要 .NET 4.7.1 SDK  
只要 SDK 內有 al.exe al.exe.config 兩個檔案就可以 ，4.0 的就複製到4.0 的資料夾內，3.5的就複製到3.5的資料夾內 ，Framework 是x86資料夾，Framework64 是x64資料夾  
複製檔案時不要弄錯就好

資源裡的代碼不做修改

常用字體
日語字形：MS Gothic、MS PGothic、MS UI Gothic （1041）
SimHei：早期常用黑體
MS YaHei：後期用的字形
apk.tw 提到關於MS缺少大陸字型
Passolo 匯出後再匯入翻譯，無法一鍵翻譯
更換字體使用ResScope跟換，不行再用Restorator或Resource Hacker
非標字元：點睛中文化 ^87ee7a

 
Visual C++ 6 中文化
```
STRINGTABLE
LANGUAGE 4, 2 (4代表中文 2代表繁體中文)
{
    1001 "開啟檔案"
    1002 "儲存檔案"
    1003 "取消"
}
```

VC++ 8 中文化



Borland C++
改RC Data裡面的Font.Charset=CHINESEBIG5_CHARSET
例nrLaunch，字串都在Unicode、UTF8中
用ResScope在簡體中文的系統繁體化RCData
![gh](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1749263151000hkakpw.png)

#### VB簡體繁化亂碼
Microsoft Visual Basic程式簡體版繁體中文化後出現亂碼（字體的修改）的處理  
使用：CXAT 2.5中文化軟體中文化之後….因字體編碼關係…部分字串出現亂碼  
圖片如下：  
使用：UltraEdit-32開啟後之文字編碼圖片如下：  
修正後就可以用啦！  
1、 使用UltraEdit-32軟體→搜尋 86 00 00 90 01 →注意他的後面有無→冼极  
（如果有）→修改成→ 88 00 00 90 01  
2、 使用UltraEdit-32軟體→搜尋 86 00 00  →注意他的後面有無→冼极  
（如果有）→修改成→ 88 00 00  
※、特殊情況：→找到字串（ASCII）確定已經中文化→變成亂碼！
 在字串之後→冼极（之前）→找到86 00（86 00 04 90 10）→修改成  → 88 00（88 00 04 90 10）  
===============================================================  
說明：  
Visual Basic程式的字體，雖然全是ASCII文字，但最為難搞的傢伙！  
在5.0版本以前，就在字體文字之前有一串字體控制碼(十六進)。  
25 01 00 00 00 90 01在MS Sans Serif之前 【英文版】  
25 01 88 00 00 90 01在新細明體之前  【繁體中文版】  
25 01 86 00 00 90 01在冼极(宋體)之前 【簡體中文版】  
最前的25 01是指Label物件，不同的物件，有不同的編碼，90 01是標準字型。  
在5.0版本以後，我們只須修改：  
56 42 35 21 f0 1f 2a 00 00 00 00 00 00 00 00 00 00 = 英文字體（用UltraEdit-32觀看是 VB5!）  
56 42 35 21 f0 1f 00 00 00 00 00 00 00 00 00 00 00 = 預設字體（一般有效，但亦會無效，要指定字體）  
56 42 35 21 f0 1f 56 42 36 43 48 54 2e 44 4c 4c 00 = vb6cht.dll繁體中文字體  
56 42 35 21 f0 1f 56 42 36 43 48 52 2e 44 4c 4c 00 = vb6chr.dll簡體中文字體  
但有一些程式是複合了不同版的的obj, 我們可能要做齊全部的工作.

#### Delphi 及 C++Builder簡繁亂碼
如果：使用【CXAT】軟體去把簡體中文程式轉譯成繁體後，會發現部分的文字是：亂碼！  
【字型】:
Font.Name =MS Sans Serif 【英文版】Font.Name =其他英文字型 【英文版】Font.Name =細明體【繁體中文
Font.Name =新細明體【繁體中文版】Font.Name =冼极 【簡體中文版】Font.Name =宋体【簡體中文版】

亂碼不是翻譯錯誤，是選錯了字形檔！
**Delphi** **及** **C++ Builder** **的字形檔標簽文字：
Font.Charset=GB2312_CHARSET  簡體
Font.Charset=CHINESEBIG5_CHARSET 繁體
Font.Charset=DEFAULT_CHARSET  英文  
  
要修改字形，可以選用ResScope9.6工具，  
把GB2312_CHARSET，全部改成CHINESEBIG5_CHARSET  
經過再編譯及存檔後，就會得到不亂碼的繁體中文程式。但是：如果程式是經過加殼，而脫殼又不完整時，就不可能使用ResScope9.6工具。  
事實上：要把簡體字形轉成繁體字形，並不一定要用重組資源的方法，還可以使用移花接木的方法，  
甚麼是移花接木法，就是更改**字形標簽的名****稱**：  
把GB2312_CHARSET指向繁體字形來達到目的！  

**  
移花接木的方法：**  
使用UltraEdit-32軟體開啟中文化後的程式，點選【搜尋】→【取代】→ 不要勾選（ASCII）  
**簡體轉繁****體：  
搜尋：（複製→貼上）以下字串**  
4742323331325F434841525345540000FFFFFFFF130000004348494E455345424947355F43484152534554 
**取代為：（複製→貼上）以下字串**  
4742323331335F434841525345540000FFFFFFFF0E0000004742323331325F434841525345549090909090

#### LNG翻譯
  一般軟體中文化最直接就是：直接中文化主程式或DLL資源檔案  
  **支援多國語系的軟體就不必那麼麻煩！中文化語系檔就可以啦！**  昨天看到一個軟體：WinMount v3.2.0213  
  他的中文化比較特殊（不是把語系改成zh-tw名稱的中文化語系）  
  **以下是我的中文化處理過程：**  
  WinMount v3.2.0213安裝後是：英文版（此軟體支援多國語系）  
  主程式是：WinMount3.exe  
  **目錄下有一個：Lang.dll檔案  
  還有一個：lang語系檔的目錄**  
  **該官方有所謂的：官方中文語系（其實是：大陸簡體中文…並非台灣繁體中文）**  
  **啊！又是一個不重視【台灣】存在…【西瓜靠大邊】的悲哀！**  
  **台灣人自應當【自強】…我來教大家如何快速變成：台灣繁體中文版**  **大陸簡體中文語系代碼為：936  
  台灣繁體中文語系代碼為：950**  
  **所以要變成台灣繁體中文版首先將：lang目錄下的936.xml與wmmou936.xml用文字編輯器開啟  使用ConvertZ：將簡體轉成繁體中文（另存新檔）→950.xml與wmmou950.xml  這樣就可以啦！重新開啟程式後你會發現：程式會自動變成台灣繁體中文版**  
  **軟體中文化技術是：台灣人不必受【西瓜靠大邊】的【窩囊氣】！  台灣人要自立自強，不要怨天尤人！**  
  **哈哈！在國際上有很多好的高級商品都是：【台灣製造】！**  
  **上菜啦！各位看倌請慢用！**

#### UPX3脫殼錯誤用ImportREC 修復


#### **Delphi TFontCharset - 字符集**
- ANSI_CHARSET = 0;
- DEFAULT_CHARSET = 1;
- SYMBOL_CHARSET = 2;
- SHIFTJIS_CHARSET = $80;
- HANGEUL_CHARSET = 129;
- GB2312_CHARSET = 134;
- CHINESEBIG5_CHARSET = 136;
- OEM_CHARSET = 255;
- JOHAB_CHARSET = 130;
- HEBREW_CHARSET = 177;
- ARABIC_CHARSET = 178;
- GREEK_CHARSET = 161;
- TURKISH_CHARSET = 162;
- VIETNAMESE_CHARSET = 163;
- THAI_CHARSET = 222;
- EASTEUROPE_CHARSET = 238;
- RUSSIAN_CHARSET = 204;
- MAC_CHARSET = 77;
- BALTIC_CHARSET = 186;

#### 翻譯ini檔案 
Lingobit Localizer Enterprise：可快速翻譯ini

[用Multizer 中文化過程](http://stenwang.blogspot.com/2015/09/blog-post_23.html?m=1)
YT，[【教程】教你如何汉化Windows软件](https://youtu.be/mjRbmA5YB-Q?si=Xbrglje4tOlS7cpP)

#### 字典檔翻譯
![[CAT 補助翻譯]]

### PDF 翻譯工具 【5个免费 PDF 翻译开源项目，完美保留原文档布局！轻松搞定表格、公式翻译！PDFMathTranslate|Babeldoc|PolyglotPDF-哔哩哔哩】 https://b23.tv/TtTfiL6
### 格式工廠去廣告
<!–去界面的广告主页按钮 FormatFactory.exe –!>  
用CFFExplorer->主程序->资源编辑器资源->241  
->128 //将最后4个十六进制字节修改为00，保存

<!–去界面图片功能区域：图片工厂下载按钮栏–!>  
用x64dbg附加进入程序反汇编指令处，搜索字符串：  
mov ds:[7FF6DE19F6A8],2 //改为4 相关字符填充00  
lea r8,ds:[7FF6DE155FC0] “Picosmos Picture Tools”  
00007FF6EE2D5FF0: “:/res/PicosmosTools.png”

<!–禁止默认检测升级，去除后续检测升级提示–!>  
搜索字符串 CheckNewVersion 第四处字符串上这句指令  
mov r9d, 1 改为mov r9d, 0，另存修改文件 FTMedia.dll  
继续搜索Fail to connect update server! 领空改为ret  
继续搜索updatelog.txt ~将上面的je改为jnz~~

### 去除exe更新
https://www.52pojie.cn/thread-1165909-1-1.html

#### 參考資料
1. 漢化新世紀（目前以關站） ^eeaec2
2. 史萊姆論壇中文化討論區，http://forum.slime.com.tw/f52.html
3. 漢化新世紀存檔頁面https://web.archive.org/web/20150516093924/http://www.hanzify.org/category/91.html
4. cpatch中文化軟體資源，http://ftp.twaren.net/cpatch/patchutil/。
5. 中文化譯站：https://zochen.tripod.com/cgi-bin/teach.cgi
6. 數碼中文化：https://www.suma.tw/forum-48-1.html

重要文章：https://apk.tw/thread-941848-1-1.html
中文化資源：https://conc1.pixnet.net/blog/post/102085840
中文化工具：https://ericcpatch.tripod.com/tool1.htm
