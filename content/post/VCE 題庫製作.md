---
title: VCE題庫製作
toc: true
date: 2026-06-21
---
清理PDF格式
1.在Acrobat先轉成docx
2.Word取代：^b取代為空字串、統一頁面邊界1.5、段落單行間距前後段0行
因為要在Question #1… 前面一行加入1. 讓Designer 判別，使用VBA
```
1. 
Question #1 
Answer: 
2. 
Question #2 
Answer:
```

```vb
Sub InsertNumberBeforeQuestions()
    Dim para As Paragraph
    Dim count As Integer
    count = 1
    
    For Each para In ActiveDocument.Paragraphs
        If InStr(1, para.Range.Text, "Question #", vbTextCompare) > 0 Then
            para.Range.InsertBefore count & "." & vbCrLf
            count = count + 1
        End If
    Next para
End Sub
```
刪掉大量分節符號 ^b 取代為空

匯入畫面
![](static/image.png)
![](image%201.png)
![](image%202.png)
![](image%203.png)