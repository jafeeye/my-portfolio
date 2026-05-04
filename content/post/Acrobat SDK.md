Powershell 一直出錯，原因不明

CMD 下命令 (可以加上雙引號)
```shell
cscript //nologo "C:\Apps\OpenWithPP\shell\ConvertPDFtoWord.vbs" "C:\Users\PIN\Desktop\123.pdf"
```
改成Open With++
```shell
Path=C:\Windows\System32\cmd.exe
Arguements=/c cscript "C:\Apps\OpenWithPP\shell\ConvertPDFtoWord.vbs" %paths%
```
ConvertPDFtoWord.vbs
```vb
' 獲取右鍵傳入的 PDF 文件路徑
FilePath = WScript.Arguments(0)
' 創建 Acrobat COM 對象
Set AcrobatApp = CreateObject("AcroExch.App")
Set AVDoc = CreateObject("AcroExch.AVDoc")
' 打開 PDF 文件
If Not AVDoc.Open(FilePath, "") Then
    WScript.Echo "錯誤：無法打開 PDF 文件 - " & FilePath
    WScript.Quit
End If
' 獲取 PDDoc 和 JSObject
Set PDDoc = AVDoc.GetPDDoc()
Set Jso = PDDoc.GetJSObject()
' 定義新文件名（將 .pdf 替換為 .docx）
NewFileName = Replace(FilePath, ".pdf", ".docx")
' 保存為 Word 文檔
On Error Resume Next
Jso.SaveAs NewFileName, "com.adobe.acrobat.docx"
' 清理資源
AVDoc.Close True
AcrobatApp.Exit
Set PDDoc = Nothing
Set AVDoc = Nothing
Set AcrobatApp = Nothing
```

#### 參考資料
1. [How to convert PDF to Word using Acrobat SDK? [closed]](https://stackoverflow.com/questions/11341073/how-to-convert-pdf-to-word-using-acrobat-sdk)
2.  [Acrobat-PDFL SDK: JavaScript Reference](https://opensource.adobe.com/dc-acrobat-sdk-docs/library/jsapiref/toc.html)