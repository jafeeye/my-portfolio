函数名(参数1,参数2){函数内容写在这里}
```AutoHotKey
text_paste_zz(getZz := ""){ ;定義text_paste_zz函數，參數getZz，
ClipSaved := ClipboardAll  ; 備份原剪貼簿
Clipboard := getZz         ; 把getZz放到剪貼簿
ClipWait, 1                ; 等待剪貼簿生效
    Run, %Snipaste% paste --files %getZz%
    Sleep, 300
    Clipboard := ClipSaved     ;還原剪貼簿
	}
```

目錄寫法
```
A_ScriptDir . "\ScreenCapture.exe"  ;根目錄
```

不搶光標：設置WinSet及最上層
```
WinSet, ExStyle, ^0x08000000,ahk_class
WinSet, ExStyle, +0x08000000,ahk_id %hGUI% WS_EX_NOACTIVATE
Gui, +AlwaysOnTop
```

簡易寫法：選取檔案複製路徑(進剪貼簿)
```
Clipboard := ""    ; 清空剪貼簿
Send, ^c           ; 模擬 Ctrl+C 複製選取內容
ClipWait, 0.2      ; 等待 0.2s
pathText := Chr(34) . Clipboard . Chr(34) ; 回傳加引號的剪貼簿內容
Clipboard := pathText
```
Claunahk進階寫法：選取檔案複製路徑傳送至變數(不丟剪貼簿)
```
ClipSaved := ClipboardAll
Clipboard := """"
Send, ^c           ;模擬選取複製
ClipWait, 0.2      ;等待0.2s
pathText := Chr(34) . Clipboard . Chr(34) ; 回傳加引號的剪貼簿內容
Clipboard := pathText
```



瀏覽器參數
```
"C:\Program Files\Vivaldi\Application\vivaldi.exe" --force-renderer-accessibility --new-window --window-size=1024,768 "https://www.deepl.com/translator/m/translate#auto/cn/%s""

-app=
"C:\Program Files\Vivaldi\Application\vivaldi.exe" --force-renderer-accessibility --app="https://www.deepl.com/translator/m/translate#auto/cn/%s" --window-size=1024,768

```


**寫法注意**
`%名稱%` 展開名稱為變數意思
`SetThreadDpiAwarenessContext` 真實像素座標Win10+ 
`IniRead` 原為呼叫 WinAPI `GetPrivateProfileString()` 只支援ANSI或UTF-16 LE
`Clipboard` 系統剪貼簿名稱  %Clipboard%
TestT：= 123 ;Test宣告變數值為123
Test=123 ;Test為123但不是變數，下面要當變數取用要用%Test%  abc=%Test%
`~RButton`：保留系統右鍵並偵測右鍵
程式碼有中文：UTF-8 BOM儲存
偵測軟體運行：WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)

微軟正黑體會有模糊問題, 雅黑雖然繁體字對不齊但不會有不清晰問題, Noto CJK就可以解決
變量複製剪貼簿 `clipboard:=var` 或  `clipboard=%var%`

獲取輸入光標位置：https://meta.appinn.net/t/topic/38034
設定啟動器顯示不搶前景  CLaunchWndClass` 解決思路是指向0x80風格 [|[程式筆記#^097fbb]]


快速鍵複製路徑.ahk
```AutoHotkey
^+c::
Clipboard := gst()
if !IsClipEmpty
ClipWait, 0.5, 1
gst() {   ; GetSelectedText or FilePath in Windows Explorer  by Learning one
IsClipEmpty := (Clipboard = "") ? 1 : 0
if !IsClipEmpty {
    ClipboardBackup := ClipboardAll
    While !(Clipboard = "") {
        Clipboard =
        Sleep, 10
    }
}

Send, ^c
ClipWait, 0.1
ToReturn := Clipboard, Clipboard := ClipboardBackup
if !IsClipEmpty
ClipWait, 0.5, 1
Return ToReturn

}
```

TTS
```
AHK設定快捷鍵：幫助朗讀用整篇朗讀的話，沒辦法重複的聽和記憶
功能  
ctrl+Down 移到下一行，把該行存到剪貼簿，再送出f9(朗誦剪貼簿）  
ctrl+UP 移到上一行，把該行存到剪貼簿，再送出f9(朗誦剪貼簿）  
ctrl+right 把該行存到剪貼簿，再送出f9(朗誦剪貼簿）  
ctrl+c  存到剪貼簿，再送出f9(朗誦剪貼簿）  
＝＝＝＝＝＝＝＝＝把以下的內容存到ahk==============  
#IfWinActive ahk_exe Balabolka.exe  
^c::  
     Send ^{c}  
      Send {f9}  
      return  
^Right::  
       Send {End}{LShift down}{Home}{LShift up}  
       Send ^c  
       ClipWait,1  
        Send {f9}  
        return  
#IfWinActive  
  
^up::  
    IfWinActive ahk_exe Balabolka.exe  
       {  
       Send {Up} {End}{LShift down}{Home}{LShift up}  
       Send ^c  
       ClipWait,1  
        Send {f9}  
                   }  
    else  
       send {vkAFsc130}   ;調整聲音大聲  
    return  
  
  
^down::  
    IfWinActive ahk_exe Balabolka.exe  
       {  
       Send {Down} {End}{LShift down}{Home}{LShift up}  
       Send ^c  
       ClipWait,1  
        Send {f9}  
                   }  
     else  
       {  
        send {vkAEsc12E}  ;調整聲音小聲  
       }  
   return
```


