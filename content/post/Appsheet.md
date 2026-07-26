在Data下代表意思
![[Pasted image 20241117183417.png]]


![[Pasted image 20241117183635.png]]

下面是從創立表格到在 AppSheet 中完成隨機顯示一列資料的詳細步驟：

### 步驟 1：創建 Google Sheets 表格

1. **創建 Google 表格：**
   - 打開 [Google Sheets](https://sheets.google.com) 並創建一個新的表格。
   - 命名該表格，例如「`MyTable`」。

2. **設置表格欄位：**
   - 在表格中，創建以下欄位：
     - **ID**：唯一的識別碼欄位，通常可以是數字。
     - **Name**：資料欄位，可以是您想顯示的資料（例如名字、描述等）。
     - **Description**：選填，您可以添加更多的資料欄位來存儲詳細內容。

   範例表格結構：

   | ID  | Name   | Description |
   |-----|--------|-------------|
   | 1   | Item A | Description A |
   | 2   | Item B | Description B |
   | 3   | Item C | Description C |
   | 4   | Item D | Description D |

3. **保存 Google 表格**：確保將 Google 表格保存並關閉。

### 步驟 2：創建 AppSheet 應用

1. **創建新的 AppSheet 應用**：
   - 進入 [AppSheet](https://www.appsheet.com) 並使用您的 Google 帳戶登錄。
   - 點擊「`Make a new app`」創建一個新的應用。
   - 選擇「`Start from your own data`」，然後選擇剛才創建的 Google 表格 `MyTable`。

2. **連接 Google 表格到 AppSheet**：
   - 在 AppSheet 中，選擇「Google Sheets」並授予所需的權限。
   - AppSheet 將自動將 `MyTable` 轉換為應用中的一個資料表。

### 步驟 3：創建虛擬列生成隨機數字

1. **進入表格設置**：
   - 在 AppSheet 的左側導航欄中，選擇「`Data`」 > 「`Columns`」，然後選擇您的資料表 `MyTable`。

2. **添加虛擬列**：
   - 在 `Columns` 頁面中，點擊「`+ Add Virtual Column`」來添加一個新的虛擬列。
   - 在「Column Name」中輸入 `RandomNumber`，這將是用來生成隨機數字的虛擬列名稱。

3. **設定公式**：
   - 在「App formula」框中輸入以下公式，這將隨機生成一個數字，範圍從 1 到資料表 `MyTable` 的總行數：
   ```plaintext
   RANDBETWEEN(1, COUNT(MyTable[ID]))
   ```
   - 點擊「Save」來保存此虛擬列。

   這個公式會隨機生成一個介於 1 到 `MyTable` 中行數之間的數字，每次頁面刷新時數字會改變。

### 步驟 4：創建虛擬列選擇隨機資料行

1. **添加另一個虛擬列**：
   - 點擊「`+ Add Virtual Column`」再次創建一個新的虛擬列。
   - 設定「Column Name」為 `RandomRow`。

2. **設定公式來選擇隨機行**：
   - 在「App formula」框中，輸入以下公式來根據 `RandomNumber` 列查找對應的資料行：
   ```plaintext
   LOOKUP([RandomNumber], MyTable, "ID", "Name")
   ```
   - 這個公式會根據 `RandomNumber` 隨機數字，在 `MyTable` 中查找對應的 `ID`，並返回該行中的 `Name` 欄位值（您也可以選擇其他欄位，如 `Description`）。
   
3. **保存更改**：
   - 點擊「Save」來保存此虛擬列。

### 步驟 5：創建視圖來顯示隨機資料

1. **創建一個新的視圖**：
   - 在左側導航欄中，選擇「`UX`」 > 「`Views`」，然後點擊「`+ New View`」來創建新的視圖。
   
2. **設置視圖配置**：
   - 設定「View Name」，比如 `RandomItem`，並選擇視圖類型（如「Table」或「Card」）來顯示資料。
   - 在「Data」選項卡中，選擇資料來源為 `MyTable`。

3. **設置顯示欄位**：
   - 在「Column order」中，確保 `RandomRow` 欄位被添加到視圖顯示中，這樣隨機的資料行將顯示在應用的視圖中。

4. **保存視圖設置**：
   - 點擊「Save」來保存視圖設定。

### 步驟 6：測試應用

1. **預覽應用**：
   - 在 AppSheet 中，您可以點擊「Preview」來查看應用的效果。
   - 每次重新加載應用或刷新視圖，`RandomNumber` 會生成新的隨機數字，並且 `RandomRow` 將顯示新的隨機資料行。

2. **發布應用**：
   - 完成測試後，您可以選擇「Not Deployed」進行發布，將應用分享給其他使用者。

### 完成

您現在已經成功創建了在 AppSheet 中隨機顯示一列資料的應用。每次刷新應用或頁面時，隨機的資料將會顯示在您的應用中。

### 小貼士：
- **控制隨機更新頻率**：如果您希望隨機數字不是每次都改變，可以考慮添加條件觸發器來控制 `RANDBETWEEN` 的更新頻率，例如在某些操作後才更新隨機數字。
- **顯示更多資料**：除了 `Name`，您也可以顯示更多欄位（例如 `Description`），只需修改 `LOOKUP` 函數中的返回欄位即可。

希望這些步驟能幫助您順利完成在 AppSheet 中隨機顯示資料的設置！






好的，讓我們把 Google Sheets 進行一些擴展，讓每個產品都包含名稱和內容，然後在 AppSheet 中顯示隨機選擇的產品名稱及對應的產品內容。

### **更新的 Google Sheets 資料**

假設你有一個 Google Sheets，資料擴展成這樣：

| 產品名稱 | 產品內容 |
| ----- | ----- |
| 產品A | 這是產品A的描述 |
| 產品B | 這是產品B的描述 |
| 產品C | 這是產品C的描述 |
| 產品D | 這是產品D的描述 |
| 產品E | 這是產品E的描述 |

資料位於 `Sheet1`，`A2:A6` 是產品名稱，`B2:B6` 是產品內容。

### **步驟 1: 準備 Google Sheets 資料**

Google Sheets 資料現在看起來像這樣：

| 產品名稱 | 產品內容 |
| ----- | ----- |
| 產品A | 這是產品A的描述 |
| 產品B | 這是產品B的描述 |
| 產品C | 這是產品C的描述 |
| 產品D | 這是產品D的描述 |
| 產品E | 這是產品E的描述 |

### **步驟 2: 在 AppSheet 中設置隨機顯示資料**

1. **創建應用**：  
   * 打開 [AppSheet](https://www.appsheet.com/)，並創建一個新的應用，選擇從 **Google Sheets** 中導入資料。  
   * 選擇你的 **Google Sheets**，並將 `Sheet1` 作為資料表添加進來。  
2. **創建虛擬欄位來顯示隨機資料**：  
   * 在 **AppSheet** 中，進入「Data」\>「Columns」，選擇你的資料表（例如 `Sheet1`）。  
   * 點擊「+ Add Virtual Column」來創建一個新的虛擬欄位。這個虛擬欄位將顯示隨機選擇的產品名稱。  
   * 命名這個虛擬欄位為 `隨機產品名稱`。

**使用 `RANDBETWEEN` 和 `SELECT` 組合來隨機選擇產品名稱和內容**： 在 `隨機產品名稱` 這個虛擬欄位中，使用以下公式來隨機選擇一個產品名稱：  
plaintext  
複製程式碼  
`INDEX(`  
    `SELECT(Sheet1[產品名稱], TRUE),`  
    `RANDBETWEEN(1, COUNT(SELECT(Sheet1[產品名稱], TRUE)))`  
`)`

3. 這個公式的作用是：  
   * `SELECT(Sheet1[產品名稱], TRUE)`：選擇 `Sheet1` 中所有的 `產品名稱`，並將它們作為一個列表返回。  
   * `COUNT(SELECT(Sheet1[產品名稱], TRUE))`：計算 `產品名稱` 列中的資料數量，這裡使用的是 `COUNT()` 函數，它會返回 `SELECT()` 所選擇的資料項的數量。  
   * `RANDBETWEEN(1, COUNT(...))`：生成一個隨機數字，範圍從 1 到資料總數（即 `產品名稱` 列的總行數）。  
   * `INDEX(...)`：使用 `INDEX` 函數來根據隨機數字選擇對應的資料。  
4. **創建一個虛擬欄位來顯示隨機選擇的產品內容**： 接下來，創建另一個虛擬欄位來顯示隨機選擇的 `產品內容`。  
   * 點擊「+ Add Virtual Column」並創建名為 `隨機產品內容` 的虛擬欄位。

在公式欄中，使用以下公式來根據隨機選擇的產品名稱顯示對應的產品內容：  
plaintext  
複製程式碼  
`INDEX(`  
    `SELECT(Sheet1[產品內容], [產品名稱] = [隨機產品名稱]),`  
    `1`  
`)`

*   
5. 這個公式的作用是：  
   * `SELECT(Sheet1[產品內容], [產品名稱] = [隨機產品名稱])`：選擇 `Sheet1` 中 `產品名稱` 與 `隨機產品名稱` 一致的所有 `產品內容`。這樣就可以選擇到隨機選擇的產品名稱對應的產品內容。  
   * `INDEX(..., 1)`：使用 `INDEX` 函數來選擇對應的內容。

### **步驟 3: 顯示隨機資料**

1. 在 **AppSheet** 的「UX」\>「Views」中，創建一個新的「Detail View」來顯示這些隨機選擇的資料。  
2. 在該視圖中顯示 `隨機產品名稱` 和 `隨機產品內容` 這兩個虛擬欄位。每次用戶打開此視圖時，AppSheet 會隨機顯示一個產品名稱及對應的產品內容。

### **步驟 4: 測試與顯示**

1. 打開你的 **AppSheet** 應用，並進入你創建的「Detail View」。  
2. 每次進入該視圖時，AppSheet 會隨機選擇一個 `產品名稱` 和對應的 `產品內容`，並顯示出來。

### **範例：**

假設你的 **Google Sheets** 中的資料如下：

| 產品名稱 | 產品內容 |
| ----- | ----- |
| 產品A | 這是產品A的描述 |
| 產品B | 這是產品B的描述 |
| 產品C | 這是產品C的描述 |
| 產品D | 這是產品D的描述 |
| 產品E | 這是產品E的描述 |

*   
  如果 **AppSheet** 隨機顯示的結果是：  
  * `隨機產品名稱`：`產品C`  
  * `隨機產品內容`：`這是產品C的描述`  
* 如果重新刷新或加載應用，可能會顯示：  
  * `隨機產品名稱`：`產品A`  
  * `隨機產品內容`：`這是產品A的描述`

### **小結**

* **Google Sheets** 保持不變，資料包括產品名稱和對應的產品內容。  
* **AppSheet** 會根據 `RANDBETWEEN` 隨機選擇一個產品名稱，並通過 `INDEX` 函數顯示隨機選擇的產品內容。  
* 每次用戶加載應用時，隨機選擇的產品名稱及其內容會變動。

希望這個解決方案對你有幫助！如果有任何問題或需要更多的幫助，隨時告訴我！
