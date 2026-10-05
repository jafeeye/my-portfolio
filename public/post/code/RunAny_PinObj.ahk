;************************
;* 【ObjReg自訂脚本 】
;************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;********************************************************************************
#Include %A_ScriptDir%\RunAny_ObjReg.ahk

class RunAnyObj {
	;[新建：你自己的函数]
	;保存到RunAny.ini为：菜单项名|你的脚本文件名RunAny_PinObj[你的函数名](参数1,参数2)
	;你的函数名(参数1,参数2){
	;函数内容写在这里
	
    clip_zz(getZz:=""){
	    ;重要:程式碼沒有選取就不會執行，跟有無宣告global無關
	    oldClip := ClipboardAll
	    Clipboard := "" 
	    SendInput,^c
	    ClipWait, 1, 1       ; 1,1 (等1s,接受任何資料) (ClipWait,0 只檢查純文字)
        if (!ErrorLevel) {   ;檢查剪貼版有無內容
        Sleep, 100
        ;檢查剪貼簿格式專用除錯使用 ShowClipboardFormats()
        ;clipData := ClipboardAll
        ;ShowClipboardFormats()
        
            ;======== 判斷純文字=====================================
            if DllCall("IsClipboardFormatAvailable", "UInt", 1) {
                ClipToPreview()
                return   
            }
            ;======== 判斷位圖圖片 (Bitmap) ==========================
            else if DllCall("IsClipboardFormatAvailable", "UInt", 2) {
                if DllCall("OpenClipboard", "uint", 0) {
                    hBitmap := DllCall("GetClipboardData", "uint", 2)
                    DllCall("CloseClipboard")
                    path := A_ScriptDir . "\..\RunApps\ScreenCapture\ScreenCapture.exe" 
                    Run, % path . " --pin:clipboard"
                return
                }
            }
            ;======= 判斷檔案路徑 (如拖入圖片檔) =====================
            else if DllCall("IsClipboardFormatAvailable", "UInt", 15) {
                imgFile := Clipboard
                if (hBitmap := LoadPicture(imgFile)) {
                    relPath := A_ScriptDir . "\..\RunApps\ScreenCapture\ScreenCapture.exe"
                    cmd := Format("""{}"" --pin:file,""{}""", relPath, imgFile)             
                Run, %cmd%
                return
                 }
                ;========自己亂加的 不穩定刪掉====
                if (IsTextFile(imgFile)){
                    FileRead, content, %imgFile%
                    ;MsgBox %content%
                    Clipboard := content
                    ClipToPreview()
                return
                }
                ;==========結束==============
            }
            
        } else {
            Clipboard := oldClip 
        }
    }	
	
	clipcheck_zz(getZz:=""){
	    oldClip := ClipboardAll
	    Clipboard := "" 
	    SendInput,^c
	    ClipWait, 1, 1 ; 等待1s, 接受任何資料(預設0只檢查純文字)
        if (!ErrorLevel) {
        Sleep, 100
        ShowClipboardFormats()
            }
        }
	
	pasteex_zz(getZz:=""){
	    global pasteex
	    pasteex := A_ScriptDir . "\..\RunApps\PasteEx\PasteEx.exe"
	    oldClip := ClipboardAll
	    Clipboard := "" 
	    SendInput,^c
	    ClipWait, 1
	    if (!ErrorLevel && Clipboard) {
            Sleep, 100
	    Run, %pasteex% paste "%A_Desktop%\12"
	    }
	    
	}
	
	clipdirtree_zz(getZz:=""){
	    selected := getSelected()
	    if (selected = "") {                 ;當判斷explorer沒選中物件
            path := GetExplorerPath()
            ;MsgBox % GetExplorerPath()
            if (path != ""){
            outputFile := path . "\output.txt"
            RunWait, %ComSpec% " /c tree /f "%path%" > "%outputFile%", , Hide 
            } 
	    } else {                              ;傳回getZz路徑, 但這樣沒有單純判斷是否為檔案或資料夾
            Send, ^c  ; 模擬按下 Ctrl+C
            ClipWait, 0.1  ; 等待剪貼簿更新
            pathText := Clipboard
            RunWait, %ComSpec% " /c tree /f "%pathText%" > "%pathText%\output.txt", , Hide 
        }
	}


	
;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════=════════════════════════════════=═══════
}
;══════════════════════════大括号以下是獨立函數══════════════════════════════════════════════════════════════════════════════

global xx1 := A_Temp "\clip1.html"
global xx2 := A_Temp "\clip2.html"
global xx3 := A_Temp "\clip3.html"


; 隱藏或顯示 GUI 窗口用 Shift+F4
DetectHiddenText, On
shift_f3_flag := 0
$+F4::
    if (!shift_f3_flag)
        WinHide, %A_ScriptName%
    else
        WinShow, %A_ScriptName%
    shift_f3_flag := !shift_f3_flag
    send {Shift down}{F3}{Shift up}
return

GuiClose:
GuiEscape:
    Gui Destroy
return

OnExit:
    FileDelete, %A_Temp%\*.DELETEME.html
    Gui Destroy
return

GuiSize:
    if (A_EventInfo = 1)
        return
    GuiControl, Move, WB, w%A_GuiWidth% h%A_GuiHeight%
return

;===============================================================================
;判斷explorer在前景取得目前路徑
GetExplorerPath() {
    for window in ComObjCreate("Shell.Application").Windows {
        try {
            if (window.hwnd = WinActive("A")) {
                return window.Document.Folder.Self.Path
            }
        } catch {
            continue
        }
    }
    return ""
}
	

;判斷explorer是否選取物件 https://www.autohotkey.com/boards/viewtopic.php?t=126415
getSelected() {
  hwnd := WinExist("A")
  selection := ""
  WinGetClass, class
  if (class ~= "(Cabinet|Explore)WClass") {
    for window in ComObjCreate("Shell.Application").Windows {
      try window.hwnd
      catch
        return
      if (window.hwnd = hwnd) {
        for item in window.document.SelectedItems
          selection .= item.Path "`n"
      }
    }
  }
  return Trim(selection, "`n")
}


;判斷路徑副檔名
IsTextFile(path) {
    if !FileExist(path)
        return false
    SplitPath, path,,, ext
    return ext in txt,log,md,ahk,json,csv,ini
}
;=================================================================================
ClipToPreview() {
    global xx1, xx2, xx3
    global WB
    IfExist, %xx1%
        FileDelete ,%xx1%
    IfExist, %xx2%
        FileDelete ,%xx2%
    IfExist, %xx3%
        FileDelete ,%xx3%
    
    html := ClipboardGet_HTML("html")
    FileAppend, %html%, %xx1%, UTF-8
    if (html = 0) {
        html := getHtml()
        FileAppend, %html%, %xx3%, UTF-8
    }
    html := changeHtml(html)
    if (html = 0) {
        html := getHtml()
        html := changeHtml(html)
    }
    FileAppend, %html%, %xx2%, UTF-8
    HTML_page := html

    width_outter := getClipboardMaxLineWidthPX()
    width_outter := width_outter < 250 ? 250 : width_outter
    width_outter := width_outter > 850 ? 850 : width_outter
    width_inner := width_outter + 20
    wpx := "w" width_outter
    wpx2 := "w" width_inner

    Gui New
    Gui +Resize
    Gui Add, ActiveX, x0 y0 %wpx2% h870 vWB, Shell.Explorer
    WB.silent := true

    Display(WB, HTML_page)
    while WB.readystate != 4 or WB.busy
        sleep 10

    hdiv := WB.document.getElementById("mainDiv").offsetHeight
    hdiv := hdiv > 850 ? 850 : hdiv
    hpx := "h" hdiv

    Gui +AlwaysOnTop
    Gui -Caption -Border +ToolWindow
    Gui Show, %wpx% %hpx%
}

;=====================================================================================
; 通用函數區

Display(WB, html_str) {
    Count := 0
    while FileExist(f := A_Temp "\" A_TickCount A_NowUTC "-tmp" Count ".DELETEME.html")
        Count += 1
    FileAppend, %html_str%, %f%, UTF-8
    WB.Navigate("file://" . f)
}

ClipboardGet_HTML(ByRef Data) {
    If CBID := DllCall("RegisterClipboardFormat", Str, "HTML Format", UInt)
    If DllCall("IsClipboardFormatAvailable", UInt, CBID)
    If DllCall("OpenClipboard", UInt, 0)
    If hData := DllCall("GetClipboardData", UInt, CBID, UInt)
    DataL := DllCall("GlobalSize", UInt, hData, UInt)
    , pData := DllCall("GlobalLock", UInt, hData, UInt)
    , Data := StrGet(pData, DataL, "UTF-8")
    , DllCall("GlobalUnlock", UInt, hData)
    DllCall("CloseClipboard")
    Return DataL ? Data : 0
}

changeHtml(clipHtml) {
    head = <html><head><style>*{margin: 0px;padding: 0px;}body{overflow: hidden !important;}#mainDiv{overflow-x: visible;padding: 10px;}</style></head>
    beginDiv = <body id="body1"><div id="mainDiv" contenteditable="true" >
    endDiv = </div></body>
    js = <script language="javascript" type="text/javascript">if(document.getElementsByTagName("pre")[0]!=null){var rgb = document.getElementsByTagName("pre")[0].style.backgroundColor;document.getElementById("body1").style.backgroundColor = rgb;document.getElementById("body1").style.backgroundColor = rgb;}document.onkeypress = function() {var evt = (evt) ? evt : window.event;if(evt.keyCode==80){document.execCommand("Copy");}evt.keyCode = 0;evt.returnValue = false }</script>
    endDiv := endDiv js
    beginCount := 0
    htmlTxt := ""
    Loop, parse, clipHtml, `n, `r
    {
        index := A_Index
        if (index = 6 && !A_LoopField)
            return 0
        if (index > 6) {
            tempField := A_LoopField
            if (index = 7 && strBeginWith(tempField, "<html>"))
                StringReplace, tempField, tempField, <html>, % head
            if (InStr(tempField, "<body>") && !beginCount) {
                StringReplace, tempField, tempField, <body>, % beginDiv
                beginCount += 1
            }
            htmlTxt .= tempField "`r`n"
        }
    }
    StringGetPos, position, htmlTxt, </body>, R
    str1 := SubStr(htmlTxt, 1, position)
    str2 := SubStr(htmlTxt, position + 1)
    StringReplace, str2, str2, </body>, % endDiv
    htmlTxt := str1 str2
    return htmlTxt
}

getClipboardMaxLineWidthPX() {
    a_length := 9
    b_length := 18
    clip := clipboard
    max_width_px := 0
    Loop, parse, clip, `n, `r
    {
        line := A_LoopField
        temp_width_px := 0
        Loop, parse, line
        {
            char := A_LoopField
            if (chr(char) < 128)
                temp_width_px += a_length
            else
                temp_width_px += b_length
        }
        if (temp_width_px > max_width_px)
            max_width_px := temp_width_px
    }
    return max_width_px
}

getHtml() {
    clip := clipboard
    head = <html><head><meta charset="utf-8"><style>body { background-color:#ffffff; font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;font-size:15px; color:#000000;line-height:18px;letter-spacing:1.06px; overflow: hidden !important;}</style></head><body>
    head := "1`r`n2`r`n3`r`n4`r`n5`r`n6`r`n" head
    Loop, parse, clip, `n, `r
    {
        line := A_LoopField
        StringReplace, line, line, % " ", % "&nbsp;", All
        head .= "<p>" line "</p>"
    }
    head .= "</body></html>"
    return head
}

strBeginWith(str, prefix) {
    return str != LTrim(str, prefix)
}

;-----------------------------------------------------------------------------------
;檢查剪貼簿格式函數
ShowClipboardFormats() {
    formats := ""
    Loop, 100 {
        if DllCall("IsClipboardFormatAvailable", "UInt", A_Index) {
            desc := GetFormatName(A_Index)
            formats .= "格式ID: " A_Index " - " desc "`n"
        }
    }
    
    ; 檢查一些常見的高ID註冊格式
    if (png_id := DllCall("RegisterClipboardFormat", "Str", "PNG")) {
        if DllCall("IsClipboardFormatAvailable", "UInt", png_id)
            formats .= "格式ID: " png_id " - PNG`n"
    }

    if (formats) {
        MsgBox, 0, 剪貼簿格式清單, %formats%
    } else {
        MsgBox, 0, 提示, 複製成功，但未能獲取到任何剪貼簿格式資訊。`n(這通常意味著讀取延遲問題依然存在)
    }
}


GetFormatName(fmtID) {
    static names := {1:"CF_TEXT", 2:"CF_BITMAP", 3:"CF_METAFILEPICT", 4:"CF_SYLK", 5:"CF_DIF"
        , 6:"CF_TIFF", 7:"CF_OEMTEXT", 8:"CF_DIB", 9:"CF_PALETTE", 10:"CF_PENDATA"
        , 11:"CF_RIFF", 12:"CF_WAVE", 13:"CF_UNICODETEXT", 14:"CF_ENHMETAFILE"
        , 15:"CF_HDROP", 16:"CF_LOCALE", 17:"CF_DIBV5", 18:"CF_MAX"}
        
    return (names.HasKey(fmtID) ? names[fmtID] : "（未知格式）")
}
;------------------------------------------------------------------------------------
;快速鍵explorer複製路徑
ExplorerHWND() {
    WinGetClass, class, A
    return (class = "CabinetWClass" || class = "Progman" || class = "WorkerW")
}
gst() {
    ; 檢查剪貼簿是否為空
    IsClipEmpty := (Clipboard = "") ? 1 : 0
    if !IsClipEmpty {
        ClipboardBackup := ClipboardAll  ; 備份剪貼簿內容
        While !(Clipboard = "") {       ; 清空剪貼簿
            Clipboard =
            Sleep, 10
        }
    }

    Send, ^c  ; 模擬按下 Ctrl+C
    ClipWait, 0.1  ; 等待剪貼簿更新
    ToReturn := Clipboard  ; 把複製的內容儲存為 ToReturn
    Clipboard := ClipboardBackup  ; 恢復原本的剪貼簿內容

    if !IsClipEmpty
        ClipWait, 0.5, 1  ; 等待剪貼簿更新
    return ToReturn
}

#If ExplorerHWND()
^+c:: ; 
Clipboard := gst()
if !IsClipEmpty
    ClipWait, 0.5, 1
return  ; 正確結束熱鍵動作
#If

;----------------------------------------------------------------------------
;快速鍵隱藏桌面圖示
HideDesktopIcon(){
    ControlGet, class, Hwnd,, SysListView321, ahk_class Progman
    If class =
        ControlGet, class, Hwnd,, SysListView321, ahk_class WorkerW
    If DllCall("IsWindowVisible", UInt,class)
        WinHide, ahk_id %class%
    Else
        WinShow, ahk_id %class%
}
;----------------------------------------------------------------------------
;繁簡轉換
ConvertText(convertFrom, convertTo, direction)
{
    convertZPath := A_ScriptDir . "\..\RunApps\ConvertZ\ConvertZ.exe"
    ;global convertZPath

    tmpIn := A_Temp "\convert_input.txt"
    tmpOut := A_Temp "\convert_output.txt"

    if !FileExist(convertZPath) {
        MsgBox, 找不到 ConvertZ！請確認 convertZPath 是否正確。
        return
    }

    ; 備份剪貼簿
    ClipSaved := ClipboardAll
    Clipboard := ""
    Send ^c
    ClipWait, 1
    if (Clipboard = "") {
        MsgBox, 沒有選取文字或複製失敗。
        return
    }

    FileDelete, %tmpIn%
    FileDelete, %tmpOut%

    ; ? 寫入輸入檔（僅當來源為 Unicode 時使用 UTF-16 編碼）
    if (convertFrom = "ule") {
        file := FileOpen(tmpIn, "w", "UTF-16")
        if file {
            file.Write(Clipboard)
            file.Close()
        } else {
            MsgBox, 無法寫入 Unicode 輸入檔案。
            return
        }
    } else {
        ; 不指定編碼，讓 AHK 用系統預設（ANSI）
        FileAppend, %Clipboard%, %tmpIn%
    }

    ; 執行 ConvertZ
    cmd := Format("""{1}"" /i:{2} /o:{3} /f:{4} ""{5}"" ""{6}""", convertZPath, convertFrom, convertTo, direction, tmpIn, tmpOut)
    RunWait, %cmd%, , Hide

    if !FileExist(tmpOut) {
        MsgBox, 轉換失敗，找不到輸出檔。
        return
    }

    ; ? 讀入輸出檔（僅當轉出為 Unicode 時使用 UTF-16 讀取）
    if (convertTo = "ule") {
        file := FileOpen(tmpOut, "r", "UTF-16")
        if file {
            convertedText := file.Read()
            file.Close()
        } else {
            MsgBox, 無法讀取 Unicode 輸出檔案。
            return
        }
    } else {
        ; 不指定編碼，讓 AHK 用預設 ANSI 讀取
        FileRead, convertedText, %tmpOut%
    }

    ; 貼上結果
    Clipboard := convertedText
    Sleep, 100
    Send ^v

    ; 清理與還原剪貼簿
    FileDelete, %tmpIn%
    FileDelete, %tmpOut%
    Clipboard := ClipSaved
}
return
;------------------------------------------------------------
;視窗置頂，不被Win+D影響， https://meta.appinn.net/t/topic/62229/16
Pause:: 
{
winset, AlwaysOnTop, , A
winset, ExStyle, ^0x80, A
}
return
;------------------------------------------------------------
;快速鍵關閉顯示器
MointorSleep(){
    Sleep 500 ; 让用户有机会释放按键 (以防释放它们时再次唤醒显视器).
    SendMessage, 0x112, 0xF170, 2,, Program Manager
    ;关闭显示器: 0x112 为 WM_SYSCOMMAND, 0xF170 为 SC_MONITORPOWER. 
    ;可使用 -1 代替 2 打开显示器，1 代替 2 激活显示器的节能模式
}
;-------------------------------------------------------------
;任意界面调用黑曜石Obsidian查询，或启动/激活其窗口
obsidian(){
    Loop
        Clipboard:=""
    Until (Clipboard="")
    Send ^c{Ctrl Up}
    ClipWait, 0.5
        if (ErrorLevel=0)
        {
            Text = %Clipboard%
            Text := RegExReplace(Text, "s)^\s+|\s+$", "")
            Text := RegExReplace(Text, "m)^[ `t]+|[ `t]+$", "")
            Clipboard := Text
            Run obsidian://open?vault=note,,max
            Sleep 300
            Sendinput,^+e		;設定Omnisearch快速鍵搜尋
            Sleep 200
            Sendinput,^v
            ;WinMove, A
        }
        else
        {
            Run obsidian://open?vault=note,,max
            Sleep 200
            ;WinMove, A
        }
}
;---------------------------------------------------------------------------
;快速鍵啟動/關閉軟體
ProcessExist(name) {
    Process, Exist, %name%
    return ErrorLevel
}
ToggleProgram(exeName, programPath := "") {
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    
    ; 如果未提供路徑，則使用exeName作為程式名
    if (programPath == "") {
        programPath := exeName
    }
    
    pid := ProcessExist(exeName)
    
    if (pid) {
        Process, Close, %pid%
    } else {
        Run, %programPath%
    }
}
;---------------------------------------------------------------------------
;Eagle呼叫腳本
global EagleSearchVisible := false
global EagleWindowWidth := 1200
global EagleWindowHeight := 600

; 設定座標模式為螢幕
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

; 強制將視窗設為前景
SetForegroundWindow(hWnd) {
    DllCall("SetForegroundWindow", "ptr", hWnd)
}

; 智能視窗定位函數
SmartPositionWindow(hWnd, ByRef x, ByRef y, w, h) {
    ; 取得當前螢幕工作區（排除任務欄）
    SysGet, monitorWorkArea, MonitorWorkArea
    
    ; 檢查是否超出下邊界
    if (y + h > monitorWorkAreaBottom) {
        ; 改為顯示在滑鼠右上方
        x := x + 20  ; 右移20px避免遮擋滑鼠
        y := y - h - 20  ; 上移視窗高度+20px
        
        ; 確保不超出上邊界
        if (y < monitorWorkAreaTop) {
            y := monitorWorkAreaTop
        }
        
        ; 確保不超出右邊界
        if (x + w > monitorWorkAreaRight) {
            x := monitorWorkAreaRight - w
        }
        
        ;ToolTip, 視窗位置已調整, %x%, %y%
        ;SetTimer, RemoveToolTip, -1500
    }
    
    ; 執行移動
    DllCall("MoveWindow", "ptr", hWnd, "int", x, "int", y, "int", w, "int", h, "int", true)
}

#q::
{
    DetectHiddenWindows, On

    ; 嘗試取得 Eagle 視窗 HWND
    if !WinExist("ahk_class Chrome_WidgetWin_1 ahk_exe eagle.exe")
        return
    hWnd := WinExist()

    ; 如果目前視窗是顯示狀態 → 隱藏
    if (EagleSearchVisible) {
        DllCall("ShowWindow", "ptr", hWnd, "int", 0) ; SW_HIDE
        EagleSearchVisible := false
        return
    }

    ; 還原視窗（如果最小化或在系統匣）
    ;DllCall("ShowWindow", "ptr", hWnd, "int", 9) ; SW_RESTORE

    ; 確保顯示
    ;DllCall("ShowWindow", "ptr", hWnd, "int", 5) ; SW_SHOW
    ;SetForegroundWindow(hWnd)
    
    Send, ^!q
    ; 取得滑鼠位置並智能定位
    MouseGetPos, mouseX, mouseY
    windowX := mouseX - 500
    windowY := mouseY + 10  ; 預設在滑鼠下方
    
    ; 使用智能定位函數
    SmartPositionWindow(hWnd, windowX, windowY, EagleWindowWidth, EagleWindowHeight)

    EagleSearchVisible := true
    return
}

RemoveToolTip:
    ToolTip
    return

;═══════════════════════════以下是脚本快速鍵═══════════════════════════════════════=══════════════=═══
;独立使用方式
F3::RunAnyObj.clip_zz()
#F3::RunAnyObj.clipcheck_zz()
^F3::RunAnyObj.clipdirtree_zz()
#!n::ToggleProgram("notepad.exe")
#!c::ToggleProgram("ClickShow.exe", A_ScriptDir . "\..\RunApps\ClickShow_1.41\ClickShow.exe") 
#!p::ToggleProgram("Annotator.exe", A_ScriptDir . "\..\RunApps\Annotator\Annotator.exe")
#!a::ToggleProgram("Appetizer.exe", A_ScriptDir . "\..\RunApps\Launcher_Appetizer\Appetizer.exe")
#!g::ToggleProgram("FloatingButton.exe", A_ScriptDir . "\..\RunApps\FloatingButton_3.4.1\FloatingButton.exe") 
#F1::ToggleProgram("EspansoEdit.exe", A_ScriptDir . "\..\RunApps\espanso\EspansoEdit1997\EspansoEdit.exe") 
$#1::obsidian()
#o::MointorSleep()
#!z::HideDesktopIcon()
!1::ConvertText("ule", "big5", "t")     ; Unicode 簡 → 繁
!2::ConvertText("big5", "ule", "s")     ; Big5 繁 → Unicode 簡
!3::ConvertText("gbk", "big5", "t")     ; GBK 簡體 → Big5 繁體
!4::ConvertText("big5", "gbk", "s")     ; Big5 繁體 → GBK 簡體
!5::ConvertText("jis", "ule", "s")     ; Big5 繁體 → GBK 簡體
;#!C::Run "C:\"
;#!Z::Run %A_Desktop%
;#B::Run "https://www.baidu.com/"
;#J::Run calc
;Capslock & 1::F1
;^!F9 ;Bakaloka 設定為全域按下選取就可以朗讀