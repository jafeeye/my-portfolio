---
title: Wireshark筆記
toc: true
date: 2026-05-30
---
tcpdump tcp port 502 -vv -w modbus.cap 
![](Pasted%20image%2020260530095031.png)

- Transaction Identifier：佔2個Byte，用於標示通訊的識別碼。此案例為 `00` `d1`。
- Protocol Identifier：佔2個Byte，用於表示 Modbus 協定的版本。對於Modbus TCP，它的值通常是 `00` `00`。
- Length：佔2個Byte，表示後續資料的長度，包括 Unit Identifier 。此案例為 `00` `06`。
- Unit Identifier：佔1個Byte，用於識別 Modbus 設備或單元。當多個Modbus設備連接到同一個 Modbus TCP 總線時，這個字段用於區分它們。此案例為 `01`。
- Function Code：佔1個Byte，表示 Modbus 操作的類型。功能碼用於區分讀數據、寫數據、診斷等不同的 Modbus 操作。此案例為 `01`。
- Data Field：這個字段的長度可變，根據Modbus操作的不同而異。它包含了具體的數據，例如讀取或寫入的數據。此案例為 `00` `01` `00` `01`。


可以透過 Statistics > Endpoints 看幾張網卡、幾個IP在連線
![458](Pasted%20image%2020260530095112.png)
![](Pasted%20image%2020260530095119.png)
看有哪些網卡  
可以透過 View > Name Resolution > Resolve Physical Addresses 查網卡型號和MAC地址。
![](Pasted%20image%2020260530095202.png)
