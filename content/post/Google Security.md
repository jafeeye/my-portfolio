---
title: Google Security
toc: true
date: 2026-06-01
---
CSP (Cloud Service Privoder):雲端供應商


## lessson 5
```
### 第 1 個問題

- **英文題目**：Which of the following could be examples of social engineering attacks? Select three answers.
    
- **中文翻譯**：以下哪些可能是社交工程攻擊（social engineering attacks）的例子？請選擇三個答案。
    
- **選項與解釋**：
    
    - **An unfamiliar employee asking you to hold the door open to a restricted area**：生疏的員工請求你幫忙扶門進入管制區域（屬於實體尾隨/跟隨攻擊 Tailgating）。
        
    - **An email urgently asking you to send money to help a friend who is stuck in a foreign country**：緊急要求匯款協助受困外國友人的電子郵件（屬於網路釣魚郵件）。
        
    - ~~A lost record of important customer information~~：遺失重要客戶資訊記錄（屬於資料外洩或遺失，並非社交工程）。
        
    - **A pop-up advertisement promising a large cash reward in return for sensitive information**：承諾提供大筆現金獎勵以換取敏感資訊的彈出式廣告（屬於誘餌攻擊 Baiting）。
        
- **正確答案（選三個）**：
    
    - An unfamiliar employee asking you to hold the door open to a restricted area
        
    - An email urgently asking you to send money to help a friend who is stuck in a foreign country
        
    - A pop-up advertisement promising a large cash reward in return for sensitive information
        

### 第 2 個問題

- **英文題目**：Fill in the blank: _____ uses text messages to manipulate targets into sharing sensitive information.
    
- **中文翻譯**：填空：_____ 使用文字簡訊（text messages）來操縱目標分享敏感資訊。
    
- **選項**：Smishing（簡訊釣魚）、Whaling（捕鯨攻擊/針對高階主管釣魚）、Vishing（語音釣魚）、Pretexting（藉口攻擊）。
    
- **正確答案**：
    
    - **Smishing**（簡訊釣魚）
        

### 第 3 個問題

- **英文題目**：Which of the following are not types of malware? Select two answers.
    
- **中文翻譯**：以下哪些「不是」惡意軟體（malware）的類型？請選擇兩個答案。
    
- **選項與解釋**：
    
    - **SQL injection**：SQL 注入（是一種應用程式漏洞攻擊手法，非惡意軟體）。
        
    - **Cross-site scripting**：跨站腳本攻擊（是一種網頁漏洞攻擊手法，非惡意軟體）。
        
    - Virus：病毒（惡意軟體）。
        
    - Worm：蠕蟲（惡意軟體）。
        
- **正確答案（選兩個）**：
    
    - **SQL injection**
        
    - **Cross-site scripting**
        

### 第 4 個問題

- **英文題目**：A government contractor is tricked into installing a virus on their workstation that encrypts all their files. The virus displays a message on the workstation telling the contractor that they can have the files decrypted if they make a payment of $31,337 to an email address. What type of attack is this an example of?
    
- **中文翻譯**：一名政府承包商被誘騙在工作站上安裝了會加密所有檔案的病毒。該病毒在工作站上顯示一則訊息，告訴承包商只要將 31,337 美元匯款至某個電子郵件信箱，就可以將檔案解密。這是哪種類型攻擊的例子？
    
- **選項**：Brute force attack（暴力破解攻擊）、Cross-site scripting（跨站腳本攻擊）、Scareware（驚嚇軟體）、Ransomware（勒索軟體）。
    
- **正確答案**：
    
    - **Ransomware**（勒索軟體）
        

### 第 5 個問題

- **英文題目**：Fill in the blank: Cryptojacking is a type of malware that uses someone’s device to _____ cryptocurrencies.
    
- **中文翻譯**：填空：密幣劫持（Cryptojacking）是一種使用某人設備來 _____ 加密貨幣的惡意軟體。
    
- **選項**：collect（收集）、invest（投資）、mine（挖礦）、earn（賺取）。
    
- **正確答案**：
    
    - **mine**（挖礦）
        

### 第 6 個問題

- **英文題目**：What is malicious code that is inserted into a vulnerable application called?
    
- **中文翻譯**：插入到有漏洞的應用程式中的惡意程式碼被稱為什麼？
    
- **選項**：Input validation（輸入驗證）、Social engineering（社交工程）、Injection attack（注入攻擊）、Cryptojacking（密幣劫持）。
    
- **正確答案**：
    
    - **Injection attack**（注入攻擊）
        

### 第 7 個問題

- **英文題目**：An attacker sends a malicious link to subscribers of a sports news site. If someone clicks the link, a malicious script is sent to the site's server and activated during the server’s response. This is an example of what type of injection attack?
    
- **中文翻譯**：攻擊者向體育新聞網站的訂戶發送惡意連結。如果有人點擊該連結，惡意腳本會被發送到網站伺服器，並在伺服器回應期間被激活。這是哪種類型注入攻擊的例子？
    
- **選項**：Reflected（反射型）、SQL injection（SQL 注入）、DOM-based（基於 DOM）、Stored（儲存型）。
    
- **正確答案**：
    
    - **Reflected**（反射型）
        

### 第 8 個問題

- **英文題目**：What are the reasons that an attacker would perform a SQL injection attack? Select three answers.
    
- **中文翻譯**：攻擊者執行 SQL 注入攻擊的原因有哪些？請選擇三個答案。
    
- **選項與解釋**：
    
    - **To gain administrative rights to a database**：取得資料庫的管理員權限。
        
    - **To delete entire tables in a database**：刪除資料庫中的整個資料表。
        
    - **To steal the access credentials of users in a database**：竊取資料庫中使用者的存取憑證。
        
    - ~~To send phishing messages to users in a database~~：向資料庫中的使用者發送網路釣魚訊息（SQL 注入通常用於存取/篡改資料，而非直接發送釣魚信）。
        
- **正確答案（選三個）**：
    
    - To gain administrative rights to a database
        
    - To delete entire tables in a database
        
    - To steal the access credentials of users in a database
        

### 第 9 個問題

- **英文題目**：A security team is conducting a threat model on a new software system. The team is creating their plan for defending against threats. Their choices are to avoid risk, transfer it, reduce it, or accept it. Which key step of a threat model does this scenario represent?
    
- **中文翻譯**：安全團隊正在對新軟體系統進行威脅建模（threat model）。團隊正在制定防禦威脅的計劃，他們的選擇包括：規避風險（avoid risk）、轉移風險（transfer it）、降低風險（reduce it）或接受風險（accept it）。這個情境代表威脅建模中的哪一個關鍵步驟？
    
- **選項**：Analyze threats（分析威脅）、Define the scope（定義範圍）、Evaluate findings（評估調查結果）、Mitigate risks（緩解風險）。
    
- **正確答案**：
    
    - **Mitigate risks**（緩解風險）
        

### 第 10 個問題

- **英文題目**：Which stage of the PASTA framework is related to identifying the application components that must be evaluated?
    
- **中文翻譯**：PASTA 框架中的哪一個階段與識別必須評估的應用程式組件有關？
    
- **選項**：Define the technical scope（定義技術範圍）、Implement prepared statements（實作預備語句）、Perform a vulnerability analysis（執行漏洞分析）、Characterize the environment（描述環境特徵）。
    
- **正確答案**：
    
    - **Define the technical scope**（定義技術範圍）

### 第 1 個問題

- **英文題目**：An application has broken access controls that fail to restrict any user from creating new accounts. This allows anyone to add new accounts with full admin privileges. The application’s broken access controls are an example of what?
    
- **中文翻譯**：某個應用程式具有損壞的存取控制，無法限制任何使用者建立新帳號。這允許任何人新增擁有完整管理員權限的新帳號。該應用程式損壞的存取控制是以下哪一項的例子？
    
- **選項**：
    
    - A threat（威脅）
        
    - A security control（安全控制）
        
    - An exploit（漏洞利用）
        
    - A vulnerability（弱點／漏洞）
        
- **正確答案**：
    
    - **A vulnerability**（弱點／漏洞）
        

### 第 2 個問題

- **英文題目**：Why do organizations use the defense in depth model to protect information? Select two answers.
    
- **中文翻譯**：為什麼組織要使用縱深防禦（defense in depth）模型來保護資訊？請選擇兩個答案。
    
- **選項與解釋**：
    
    - **Threats that penetrate one level can be contained in another.**：穿透一個層級的威脅可以在另一個層級中被阻絕（正確，縱深防禦的多層保護特性）。
        
    - ~~Security teams can easily determine the “who, what, when, and how” of an attack.~~：安全團隊可以輕鬆確定攻擊的「誰、什麼、何時和如何」（錯誤，這屬於事件調查或日誌分析，並非縱深防禦的主要目的）。
        
    - ~~Each layer uses unique technologies that communicate with each other.~~：各層使用彼此通訊的獨特技術（錯誤，各層不一定需要彼此通訊或使用專屬獨特技術）。
        
    - **Layered defenses reduce risk by addressing multiple vulnerabilities.**：分層防禦透過應對多重弱點來降低風險（正確）。
        
- **正確答案（選兩個）**：
    
    - **Threats that penetrate one level can be contained in another.**
        
    - **Layered defenses reduce risk by addressing multiple vulnerabilities.**
        

### 第 3 個問題

- **英文題目**：An organization's firewall is configured to allow traffic only from authorized IP addresses. Which layer of the defense in depth model is the firewall associated with?
    
- **中文翻譯**：組織的防火牆被設定為僅允許來自授權 IP 位址的流量。防火牆與縱深防禦模型的哪一個層級相關？
    
- **選項**：
    
    - Data（資料）
        
    - Endpoint（端點）
        
    - Network（網路）
        
    - Application（應用程式）
        
- **正確答案**：
    
    - **Network**（網路）
        

### 第 4 個問題

- **英文題目**：Which of the following are criteria that a vulnerability must meet to qualify for a CVE® ID? Select all that apply.
    
- **中文翻譯**：以下哪些是弱點必須符合才能獲得 CVE® 編號的標準？請選出所有適用選項。
    
- **選項與解釋**：
    
    - **It must be recognized as a potential security risk.**：必須被認為是潛在的安全風險（正確）。
        
    - ~~It must pose a financial risk.~~：必須構成財務風險（錯誤，CVE 不限於財務風險）。
        
    - **It must be independent of other issues.**：必須獨立於其他問題（正確，必須是離散且可獨立修復的弱點）。
        
    - ~~It can only affect one codebase.~~：只能影響一個程式碼庫（錯誤，可能影響多個）。
        
    - **It must be submitted with supporting evidence.**：必須提交支援證據（正確）。
        
- **正確答案（選三個）**：
    
    - **It must be recognized as a potential security risk.**
        
    - **It must be independent of other issues.**
        
    - **It must be submitted with supporting evidence.**
        

### 第 5 個問題

- **英文題目**：Which of the following are characteristics of the vulnerability management process? Select two answers.
    
- **中文翻譯**：以下哪些是弱點管理流程的特徵？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~Vulnerability management should be a one-time process.~~：弱點管理應該是一次性的流程（錯誤，應為持續性流程）。
        
    - **Vulnerability management should consider various perspectives.**：弱點管理應考慮各種觀點（正確）。
        
    - ~~Vulnerability management is a way to discover new assets.~~：弱點管理是發現新資產的方法（錯誤，發現資產通常是資產管理的範疇）。
        
    - **Vulnerability management is a way to limit security risks.**：弱點管理是限制安全風險的一種方法（正確）。
        
- **正確答案（選兩個）**：
    
    - **Vulnerability management should consider various perspectives.**
        
    - **Vulnerability management is a way to limit security risks.**
        

### 第 6 個問題

- **英文題目**：What is the main goal of performing a vulnerability assessment?
    
- **中文翻譯**：執行弱點評估（vulnerability assessment）的主要目的是什麼？
    
- **選項**：
    
    - To practice ethical hacking techniques（練習道德駭客技術）
        
    - To catalog assets that need to be protected（編製需要保護的資產目錄）
        
    - To identify weaknesses and prevent attacks（識別弱點並預防攻擊）
        
    - To pass remediation responsibilities over to the IT department（將修復責任轉交給 IT 部門）
        
- **正確答案**：
    
    - **To identify weaknesses and prevent attacks**（識別弱點並預防攻擊）
        

### 第 7 個問題

- **英文題目**：What are the two types of attack surfaces that security professionals defend? Select two answers.
    
- **中文翻譯**：安全專業人員防禦的攻擊面（attack surfaces）哪兩種？請選擇兩個答案。
    
- **選項**：
    
    - **Physical**（實體）
        
    - Intellectual property（智慧財產權）
        
    - Brand reputation（品牌聲譽）
        
    - **Digital**（數位）
        
- **正確答案（選兩個）**：
    
    - **Physical**
        
    - **Digital**
        

### 第 8 個問題

- **英文題目**：A project manager at a utility company receives a suspicious email that contains a file attachment. They open the attachment and it installs malicious software on their laptop. What are the attack vectors used in this situation? Select two answers.
    
- **中文翻譯**：某公用事業公司的專案經理收到一封包含檔案附件的可疑電子郵件。他們打開附件，該附件在他們的筆記型電腦上安裝了惡意軟體。在這種情況下使用的攻擊媒介（attack vectors）是什麼？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~The malicious software~~：惡意軟體（這是惡意酬載 malware payload，而非攻擊媒介）。
        
    - **The suspicious email**：可疑的電子郵件（網路釣魚郵件作為進入系統的媒介）。
        
    - ~~The infected workstation~~：受感染的工作站（這是受害者目標）。
        
    - **The file attachment**：檔案附件（作為遞送惡意軟體的媒介）。
        
- **正確答案（選兩個）**：
    
    - **The suspicious email**
        
    - **The file attachment**
        

### 第 9 個問題

- **英文題目**：Which of the following are reasons that security teams practice an attacker mindset? Select three answers.
    
- **中文翻譯**：安全團隊練習攻擊者心態的原因有哪些？請選擇三個答案。
    
- **選項與解釋**：
    
    - **To uncover vulnerabilities that should be monitored**：找出應該被監控的弱點（正確）。
        
    - **To identify attack vectors**：識別攻擊媒介（正確）。
        
    - **To find insights into the best security controls to use**：深入了解要使用的最佳安全控制（正確）。
        
    - ~~To exploit flaws in an application's codebase~~：利用應用程式程式碼庫中的缺陷（錯誤，防守方採納攻擊者心態是為了防禦與分析，而非惡意利用漏洞攻擊）。
        
- **正確答案（選三個）**：
    
    - **To uncover vulnerabilities that should be monitored**
        
    - **To identify attack vectors**
        
    - **To find insights into the best security controls to use**
        

### 第 10 個問題

- **英文題目**：You are working as a security professional for a school district. An application developer with the school district created an app that connects students to educational resources. You’ve been assigned to evaluate the security of the app. Using an attacker mindset, which of the following steps would you take to evaluate the application? Select two answers.
    
- **中文翻譯**：您在某學區擔任安全專業人員。學區的一位應用程式開發人員建立了一個將學生連接到教育資源的應用程式。您被指派評估該應用程式的安全性。使用攻擊者心態，您會採取以下哪兩個步驟來評估該應用程式？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~Integrate the app with existing educational resources.~~：將應用程式與現有教育資源整合（這是開發或部署整合步驟，非攻擊者評估手段）。
        
    - **Evaluate how the app handles user data.**：評估應用程式如何處理使用者資料（正確，攻擊者常透過資料處理不當來竊取資訊）。
        
    - ~~Ensure the app's login form works.~~：確保應用程式的登入表單可以運作（這是基本功能測試，非攻擊者視角）。
        
    - **Identify the types of users who will interact with the app.**：識別將與應用程式互動的使用者類型（正確，攻擊者會藉此分析權限邊界與特權提升的切入點）。
        
- **正確答案（選兩個）**：
    
    - **Evaluate how the app handles user data.**
        
    - **Identify the types of users who will interact with the app.**

### 第 1 個問題

- **英文題目**：An employee who has access to company assets abuses their privileges by stealing information and selling it for personal gain. What does this scenario describe?
    
- **中文翻譯**：具有公司資產存取權限的員工濫用其特權，竊取資訊並將其出售以謀取私利。這個情境描述的是什麼？
    
- **選項**：
    
    - Procedure（程序）
        
    - Threat（威脅）
        
    - Regulation（法規）
        
    - Vulnerability（弱點）
        
- **正確答案**：
    
    - **Threat**（威脅 — 內部人員威脅 Insider Threat 屬於威脅的一種）
        

### 第 2 個問題

- **英文題目**：Which of the following are examples of a vulnerability? Select two answers.
    
- **中文翻譯**：以下哪些是弱點（vulnerability）的例子？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~Malicious hackers stealing access credentials~~：惡意駭客竊取存取憑證（這屬於攻擊行動／利用，非弱點）。
        
    - ~~Attackers causing a power outage~~：攻擊者造成停電（這屬於攻擊或威脅事件）。
        
    - **A malfunctioning door lock**：故障的門鎖（實體弱點）。
        
    - **An employee misconfiguring a firewall**：員工錯誤設定防火牆（配置弱點）。
        
- **正確答案（選兩個）**：
    
    - **A malfunctioning door lock**
        
    - **An employee misconfiguring a firewall**
        

### 第 3 個問題

- **英文題目**：Which of the following statements correctly describe security asset management? Select two answers.
    
- **中文翻譯**：以下哪些敘述正確描述了安全資產管理（security asset management）？請選擇兩個答案。
    
- **選項與解釋**：
    
    - **It helps identify risks.**：它有助於識別風險（正確）。
        
    - ~~It decreases vulnerabilities.~~：它會減少弱點（錯誤，資產管理本身是盤點與追蹤資產，不直接減少弱點）。
        
    - **It uncovers gaps in security.**：它能揭露安全上的漏洞或缺口（正確，透過資產盤點能發現未受保護或未被管理的盲點）。
        
    - ~~It is a one-time process.~~：這是一次性的流程（錯誤，資產管理必須持續進行）。
        
- **正確答案（選兩個）**：
    
    - **It helps identify risks.**
        
    - **It uncovers gaps in security.**
        

### 第 4 個問題

- **英文題目**：An employee is asked to email customers and request that they complete a satisfaction survey. The employee must be given access to confidential information in the company database to conduct the survey. What types of confidential customer information should the employee be able to access from the company's database to do their job? Select two answers.
    
- **中文翻譯**：某員工被要求發送電子郵件給客戶，請他們填寫滿意度調查。為了進行該調查，該員工必須被授予存取公司資料庫中機密資訊的權限。為了完成工作，該員工應該能夠從公司資料庫存取哪兩種類型的機密客戶資訊？請選擇兩個答案（基於最小特權原則 Principle of Least Privilege）。
    
- **選項與解釋**：
    
    - ~~Home addresses~~：家庭地址（發送滿意度調查信通常不需要家庭地址）。
        
    - **E-mail addresses**：電子郵件地址（寄送問卷必要資訊）。
        
    - ~~Credit card data~~：信用卡資料（完全不需要，涉及過高隱私與資安風險）。
        
    - **Customer names**：客戶姓名（寄送個人化郵件或稱呼必要資訊）。
        
- **正確答案（選兩個）**：
    
    - **E-mail addresses**
        
    - **Customer names**
        

### 第 5 個問題

- **英文題目**：What are the characteristics of restricted information? Select two answers.
    
- **中文翻譯**：受限制資訊（restricted information）的特徵是什麼？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~It is protected with less defenses.~~：受較少防禦保護（錯誤，受限制資訊通常受到最高級別的防禦）。
        
    - **It is highly sensitive.**：它高度敏感（正確）。
        
    - **It is considered need-to-know.**：它被認為是「確有需要知道（need-to-know）」才能存取的（正確）。
        
    - ~~It is available to anyone in an organization.~~：組織中的任何人都可以取得（錯誤，僅限特定授權人員）。
        
- **正確答案（選兩個）**：
    
    - **It is highly sensitive.**
        
    - **It is considered need-to-know.**
        

### 第 6 個問題

- **英文題目**：Why is it so challenging to secure digital information? Select two answers.
    
- **中文翻譯**：為什麼保護數位資訊如此具挑戰性？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~There are so many resources to dedicate to security.~~：有非常多的資源可以投入到安全性（與現實不符，多數組織資源有限）。
        
    - **Technologies are interconnected.**：技術之間是相互連線／交織的（正確，牽一髮而動全身，增加防禦複雜度）。
        
    - ~~There are no regulations that protect information.~~：沒有保護資訊的法規（錯誤，有許多法規如 GDPR、HIPAA 等）。
        
    - **Most information is in the form of data.**：大多數資訊都以資料形式存在（正確，數位資料易於複製、傳輸、修改與遠端存取，使其難以完全掌控）。
        
- **正確答案（選兩個）**：
    
    - **Technologies are interconnected.**
        
    - **Most information is in the form of data.**
        

### 第 7 個問題

- **英文題目**：What is an example of data in use? Select three answers.
    
- **中文翻譯**：下列何者是「使用中的資料（data in use）」的例子？請選擇三個答案。
    
- **選項與解釋**：
    
    - **Playing music on your phone.**：在手機上播放音樂（資料正在被處理／使用中）。
        
    - **Reading emails in your inbox.**：閱讀收件匣中的電子郵件（資料正在被使用者讀取與處理）。
        
    - **Watching a movie on a laptop.**：在筆電上觀看電影（資料正在被解碼並使用）。
        
    - ~~Downloading a file attachment.~~：下載檔案附件（這通常屬於資料傳輸中 Data in transit，或剛寫入儲存裝置成為資料靜止中 Data at rest）。
        
- **正確答案（選三個）**：
    
    - **Playing music on your phone.**
        
    - **Reading emails in your inbox.**
        
    - **Watching a movie on a laptop.**
        

### 第 8 個問題

- **英文題目**：What are some key benefits of a security plan? Select three answers.
    
- **中文翻譯**：安全計劃（security plan）的一些關鍵好處是什麼？請選擇三個答案。
    
- **選項與解釋**：
    
    - **Define consistent policies that address what’s being protected and why.**：定義一致的政策，說明保護的對象及其原因（正確）。
        
    - **Outline clear procedures that describe how to protect assets and react to threats.**：概述明確的程序，描述如何保護資產及應對威脅（正確）。
        
    - **Establish a shared set of standards for protecting assets.**：建立保護資產的共用標準（正確）。
        
    - ~~Enhance business advantage by collaborating with key partners.~~：透過與主要合作夥伴合作來增強商業優勢（這屬於商業策略，並非安全計劃的核心目標）。
        
- **正確答案（選三個）**：
    
    - **Define consistent policies that address what’s being protected and why.**
        
    - **Outline clear procedures that describe how to protect assets and react to threats.**
        
    - **Establish a shared set of standards for protecting assets.**
        

### 第 9 個問題

- **英文題目**：What NIST Cybersecurity Framework (CSF) tier is an indication that compliance is being performed at an exemplary standard?
    
- **中文翻譯**：哪一個 NIST 網路安全框架（CSF）等級（tier）表示合規性是以模範標準執行的？
    
- **選項**：
    
    - Level-4（第 4 級：Adaptive / 自適應型 — 代表組織能根據實戰與威脅調整，達到模範或最高標準）
        
    - Level-2（第 2 級：Risk-Informed / 風險告知型）
        
    - Level-1（第 1 級：Partial / 部分型）
        
    - Level-3（第 3 級：Repeatable / 可重複型）
        
- **正確答案**：
    
    - **Level-4**
        

### 第 10 個問題

- **英文題目**：Fill in the blank: The NIST Cybersecurity Framework (CSF) is commonly used to meet regulatory _____.
    
- **中文翻譯**：填空：NIST 網路安全框架（CSF）通常用於滿足法規 _____。
    
- **選項**：
    
    - fines（罰款）
        
    - procedures（程序）
        
    - compliance（合規性）
        
    - restrictions（限制）
        
- **正確答案**：
    
    - **compliance**（合規性）

### 第 1 個問題

- **英文題目**：What is the purpose of security controls?
    
- **中文翻譯**：安全控制（security controls）的目的是什麼？
    
- **選項**：
    
    - Encrypt information for privacy（加密資訊以保護隱私）
        
    - Create policies and procedures（建立政策與程序）
        
    - Establish incident response systems（建立事件應變系統）
        
    - Reduce specific security risks（減少特定的安全風險）
        
- **正確答案**：
    
    - **Reduce specific security risks**（減少特定的安全風險）
        

### 第 2 個問題

- **英文題目**：A paid subscriber of a news website has access to exclusive content. As a data owner, what should the subscriber be authorized to do with their account? Select three answers.
    
- **中文翻譯**：新聞網站的付費訂閱者可以存取獨家內容。作為資料擁有者，該訂閱者應該被授權對他們的帳號進行哪些操作？請選擇三個答案。
    
- **選項與解釋**：
    
    - **Stop their subscription**：停止他們的訂閱（正確，使用者可自主決定取消服務）。
        
    - **Review their username and password**：檢視他們的使用者名稱與密碼（正確，用戶可檢視自己的帳號憑證設定）。
        
    - **Update their payment details**：更新他們的付款詳細資訊（正確，用戶可自行管理帳單與付款方式）。
        
    - ~~Edit articles on the website~~：編輯網站上的文章（錯誤，一般訂閱者無權修改網站內容）。
        
- **正確答案（選三個）**：
    
    - **Stop their subscription**
        
    - **Review their username and password**
        
    - **Update their payment details**
        

### 第 3 個問題

- **英文題目**：Which type of encryption is generally slower because the algorithms generate a pair of encryption keys?
    
- **中文翻譯**：哪種類型的加密通常較慢，因為演算法會產生一對加密金鑰？
    
- **選項**：
    
    - Symmetric（對稱式加密）
        
    - Asymmetric（非對稱式加密）
        
    - Data encryption standard (DES)（資料加密標準）
        
    - Rivest–Shamir–Adleman (RSA)（RSA 演算法，雖然屬於非對稱式，但通稱此加密類型為 Asymmetric）
        
- **正確答案**：
    
    - **Asymmetric**（非對稱式加密）
        

### 第 4 個問題

- **英文題目**：Why are hash algorithms that generate long hash values more secure than those that produce short hash values?
    
- **中文翻譯**：為什麼產生長雜湊值的雜湊演算法比產生短雜湊值的雜湊演算法更安全？
    
- **選項**：
    
    - They are more difficult to brute force（它們更難被暴力破解）
        
    - They are more difficult to remember（它們更難記憶）
        
    - They are easier to decrypt（它們更容易解密 — 註：雜湊是單向的，不可解密）
        
    - They are easier to exchange over a network（它們更容易在網路上交換）
        
- **正確答案**：
    
    - **They are more difficult to brute force**（它們更難被暴力破解）
        

### 第 5 個問題

- **英文題目**：Fill in the blank: A _____ is used to prove the identity of users, companies, and networks in public key infrastructure.
    
- **中文翻譯**：填空：在公開金鑰基礎設施（PKI）中，_____ 用來證明使用者、公司和網路的身分。
    
- **選項**：
    
    - access token（存取權杖）
        
    - digital certificate（數位憑證）
        
    - digital signature（數位簽章）
        
    - access key（存取金鑰）
        
- **正確答案**：
    
    - **digital certificate**（數位憑證）
        

### 第 6 個問題

- **英文題目**：Fill in the blank: Knowledge, ownership, and characteristic are three factors of _____ systems.
    
- **中文翻譯**：填空：知識（Knowledge）、所有權（Ownership）與特徵（Characteristic）是 _____ 系統的三個要素。
    
- **選項**：
    
    - authorization（授權）
        
    - accounting（計費／審計）
        
    - authentication（驗證／認證）
        
    - administrative（管理）
        
- **正確答案**：
    
    - **authentication**（驗證／認證 — 即所知、所有、所有者特徵，如密碼、權杖、生物辨識）
        

### 第 7 個問題

- **英文題目**：What is a key advantage of multi-factor authentication compared to single sign-on?
    
- **中文翻譯**：與單一登入（SSO）相比，多因素驗證（MFA）的一個關鍵優勢是什麼？
    
- **選項**：
    
    - It can grant access to multiple company resources at once.（它可以一次授予對多個公司資源的存取權 — 這是 SSO 的特點）
        
    - It is faster when authenticating users.（在驗證使用者時更快）
        
    - It requires more than one form of identification before granting access to a system.（在授予系統存取權之前，它需要多於一種形式的身分識別）
        
    - It streamlines the authentication process.（它簡化了驗證過程）
        
- **正確答案**：
    
    - **It requires more than one form of identification before granting access to a system.**（在授予系統存取權之前，它需要多於一種形式的身分識別）
        

### 第 8 個問題

- **英文題目**：A business has one person who receives money from customers at the register. At the end of the day, another person counts that money that was received against the items sold and deposits it. Which security principles are being implemented into business operations? Select two answers.
    
- **中文翻譯**：某企業由一個人負責在收銀台收取客戶的錢。到了結帳時，另一個人負責將收到的錢與售出的商品進行核對並存款。這項商業營運實施了哪些安全原則？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~Multi-factor authentication~~：多因素驗證（與收銀人員驗證身分無直接對應）
        
    - **Separation of duties**：職責分離（收錢與對帳／存款由不同人執行，正確）
        
    - ~~Single sign-on~~：單一登入
        
    - **Least privilege**：最小特權（每人只擁有執行其職責所需的權限與操作範圍，正確）
        
- **正確答案（選兩個）**：
    
    - **Separation of duties**
        
    - **Least privilege**
        

### 第 9 個問題

- **英文題目**：What are common authorization tools that are designed with the principle of least privilege and separation of duties in mind? Select three answers.
    
- **中文翻譯**：哪些是設計時納入最小特權和職責分離原則的常見授權工具？請選擇三個答案。
    
- **選項與解釋**：
    
    - ~~SHA256~~：SHA256（這是一種雜湊演算法，非授權工具）
        
    - **OAuth**：OAuth（開放授權標準，常應用於授權機制，正確）
        
    - **Basic auth**：Basic auth（基本身分驗證／授權標頭機制，正確）
        
    - **API Tokens**：API 權杖（用於限制存取範圍與授權的憑證，正確）
        
- **正確答案（選三個）**：
    
    - **OAuth**
        
    - **Basic auth**
        
    - **API Tokens**
        

### 第 10 個問題

- **英文題目**：Your security team receives an alert from the organization's login server regarding multiple failed login attempts. The alert indicated that there were 10 failed login attempts to the company's customer database in the past hour. What is the first thing you should do to investigate this incident?
    
- **中文翻譯**：您的安全團隊收到來自組織登入伺服器的警報，關於多次登入失敗的嘗試。警報指出過去一小時內有 10 次對公司客戶資料庫的登入失敗嘗試。調查此事件時，您首先應該做什麼？
    
- **選項**：
    
    - Return the server's operating system to a previous version.（將伺服器的作業系統還原到先前的版本）
        
    - Perform accounting on the access logs of the system.（對系統的存取日誌進行審計／計費分析）
        
    - Disable the customer database server.（停用客戶資料庫伺服器）
        
    - Ignore the alert until you receive more user complaints.（忽略警報，直到收到更多使用者投訴）
        
- **正確答案**：
    
    - **Perform accounting on the access logs of the system.**（對系統的存取日誌進行審計／計費分析，以便了解誰在嘗試登入與調查來源）

```

## lesson 6

```
### 第 1 個問題

- **英文題目**：Which of the following is an example of a security incident?
    
- **中文翻譯**：以下哪一項是資安事件（security incident）的例子？
    
- **選項**：
    
    - **An unauthorized user successfully changes the password of an account that does not belong to them.**（未授權的使用者成功更改了不屬於他們的帳號密碼 — 屬於典型的資安事件）
        
    - An authorized user successfully logs in to an account using their credentials and multi-factor authentication.（授權使用者使用憑證與多因素驗證成功登入帳號）
        
    - A user installs a device on their computer that is allowed by an organization's policy.（使用者在電腦上安裝了組織政策允許的設備）
        
    - A software bug causes an application to crash.（軟體錯誤導致應用程式當機 — 屬於系統故障而非資安入侵事件）
        
- **正確答案**：
    
    - **An unauthorized user successfully changes the password of an account that does not belong to them.**
        

### 第 2 個問題

- **英文題目**：A security team uses the NIST Incident Response Lifecycle to support incident response operations. How should they follow the steps to use the approach most effectively?
    
- **中文翻譯**：安全團隊使用 NIST 事件應變生命週期（NIST Incident Response Lifecycle）來支援事件應變作業。他們應該如何遵循這些步驟以最有效率地使用該方法？
    
- **選項與解釋**：
    
    - **Overlap the steps as needed.**：根據需要重疊步驟（正確，NIST 事件應變生命週期的各個階段通常是相互循環與重疊的，例如從學到的經驗中反饋並調整應對措施）。
        
    - ~~Complete the steps in any order.~~：以任意順序完成步驟（錯誤，應變生命週期有其邏輯順序）。
        
    - ~~Skip irrelevant steps.~~：跳過不相關的步驟（錯誤，每個階段都至關重要）。
        
    - ~~Only use each step once.~~：每個步驟只使用一次（錯誤，事件應變往往需要反覆迭代）。
        
- **正確答案**：
    
    - **Overlap the steps as needed.**
        

### 第 3 個問題

- **英文題目**：Which core functions of the NIST Cybersecurity Framework relate to the NIST Incident Response Lifecycle? Select two answers.
    
- **中文翻譯**：NIST 網路安全框架（CSF）的哪些核心功能與 NIST 事件應變生命週期相關？請選擇兩個答案。
    
- **選項与解釋**：
    
    - ~~Discover~~
        
    - ~~Investigate~~
        
    - **Respond**：回應（NIST CSF 核心功能之一，對應事件應變）
        
    - **Detect**：偵測（NIST CSF 核心功能之一，對應事件應變中的識別與偵測）
        
- **正確答案（選兩個）**：
    
    - **Respond**
        
    - **Detect**
        

### 第 4 個問題

- **英文題目**：Fill in the blank: A specialized group of security professionals who are trained in incident management and response is a _____.
    
- **中文翻譯**：填空：一組接受過事件管理與應變培訓的專業資安人員組成的專門團體是 _____。
    
- **選項**：
    
    - forensic investigation team（數位鑑識調查團隊）
        
    - threat hunter group（威脅獵捕小組）
        
    - **computer security incident response team**（電腦安全事件應變小組 / CSIRT）
        
    - risk assessment group（風險評估小組）
        
- **正確答案**：
    
    - **computer security incident response team**
        

### 第 5 個問題

- **英文題目**：What is an incident response plan?
    
- **中文翻譯**：什麼是事件應變計劃（incident response plan）？
    
- **選項**：
    
    - **A document that outlines the procedures to take in each step of incident response**（概述事件應變每個步驟應採取之程序的文檔）
        
    - A document that details system information（詳細記錄系統資訊的文件）
        
    - A document that outlines a security team’s contact information（概述安全團隊聯絡資訊的文件）
        
    - A document that contains policies, standards, and procedures（包含政策、標準和程序的文件）
        
- **正確答案**：
    
    - **A document that outlines the procedures to take in each step of incident response**
        

### 第 6 個問題

- **英文題目**：A cybersecurity analyst receives an alert about a potential security incident. Which type of tool should they use to examine the alert's evidence in greater detail?
    
- **中文翻譯**：網路安全分析師收到有關潛在安全事件的警報。他們應該使用哪種類型的工具來更詳細地檢查警報的證據？
    
- **選項**：
    
    - A documentation tool（文件工具）
        
    - A detection tool（偵測工具）
        
    - **An investigative tool**（調查工具）
        
    - A recovery tool（復原工具）
        
- **正確答案**：
    
    - **An investigative tool**（調查工具）
        

### 第 7 個問題

- **英文題目**：Which of the following methods can a security analyst use to create effective documentation? Select two answers.
    
- **中文翻譯**：安全分析師可以使用以下哪些方法來創建有效的文件？請選擇兩個答案。
    
- **選項與解釋**：
    
    - **Write documentation in a way that reduces confusion.**：以減少混淆的方式撰寫文件（正確）。
        
    - **Provide clear and concise explanations of concepts and processes.**：提供對概念和流程的清晰簡潔解釋（正確）。
        
    - ~~Provide documentation in a paper-based format.~~：以紙本格式提供文件（錯誤，數位化文件更利於搜尋、更新與協作）。
        
    - ~~Write documentation using technical language.~~：使用過於晦澀難懂的專業技術語言撰寫文件（錯誤，過度使用艱澀術語反而增加閱讀與理解的混亂）。
        
- **正確答案（選兩個）**：
    
    - **Write documentation in a way that reduces confusion.**
        
    - **Provide clear and concise explanations of concepts and processes.**
        

### 第 8 個問題

- **英文題目**：Fill in the blank: An intrusion detection system (IDS) _____ system activity and alerts on possible intrusions.
    
- **中文翻譯**：填空：入侵偵測系統（IDS）_____ 系統活動並對可能的入侵發出警報。
    
- **選項**：
    
    - manages（管理）
        
    - **monitors**（監控）
        
    - protects（保護）
        
    - analyzes（分析）
        
- **正確答案**：
    
    - **monitors**（監控）
        

### 第 9 個問題

- **英文題目**：What is the difference between a security information and event management (SIEM) tool and a security orchestration, automation, and response (SOAR) tool?
    
- **中文翻譯**：安全資訊與事件管理（SIEM）工具和安全協調、自動化與應變（SOAR）工具之間有什麼區別？
    
- **選項**：
    
    - SIEM tools and SOAR tools have the same capabilities.（SIEM 和 SOAR 工具具有相同的功能）
        
    - **SIEM tools collect and analyze log data, which are then reviewed by security analysts. SOAR tools use automation to respond to security incidents.**（SIEM 工具收集並分析日誌資料，供安全分析師審查；SOAR 工具則使用自動化來回應安全事件）
        
    - SIEM tools use automation to respond to security incidents. SOAR tools collect and analyze log data, which are then reviewed by security analysts.（相反的敘述）
        
    - SIEM tools are used for case management while SOAR tools collect, analyze, and report on log data.（相反的敘述）
        
- **正確答案**：
    
    - **SIEM tools collect and analyze log data, which are then reviewed by security analysts. SOAR tools use automation to respond to security incidents.**
        

### 第 10 個問題

- **英文題目**：A cybersecurity professional is setting up a new security information and event management (SIEM) tool for their organization and begins identifying data sources for log ingestion. Which step of the SIEM does this scenario describe?
    
- **中文翻譯**：網路安全專業人員正在為其組織設定新的安全資訊與事件管理（SIEM）工具，並開始識別用於日誌擷取的資料來源。這個情境描述了 SIEM 的哪一個步驟？
    
- **選項**：
    
    - Normalize data（資料正規化）
        
    - Aggregate data（資料彙整）
        
    - Analyze data（資料分析）
        
    - **Collect data**（資料收集／擷取）
        
- **正確答案**：
    
    - **Collect data**
      

### 第 1 個問題

- **英文題目**：Why is network traffic monitoring important in cybersecurity? Select two answers.
    
- **中文翻譯**：為什麼網路流量監控在網路安全中很重要？請選擇兩個答案。
    
- **選項與解釋**：
    
    - **It helps identify deviations from expected traffic flows.**：它有助於識別偏離預期流量的情況（正確，能發現異常行為）。
        
    - ~~It provides a method to encrypt communications.~~：它提供了一種加密通訊的方法（錯誤，流量監控本身不負責加密）。
        
    - ~~It provides a method of classifying critical assets.~~：它提供了一種分類關鍵資產的方法（錯誤，資產分類通常透過資產管理進行）。
        
    - **It helps detect network intrusions and attacks.**：它有助於偵測網路入侵和攻擊（正確）。
        
- **正確答案（選兩個）**：
    
    - **It helps identify deviations from expected traffic flows.**
        
    - **It helps detect network intrusions and attacks.**
        

### 第 2 個問題

- **英文題目**：Which of the following behaviors may suggest an ongoing data exfiltration attack? Select two answers.
    
- **中文翻譯**：以下哪些行為可能暗示正在進行資料外洩（data exfiltration）攻擊？請選擇兩個答案。
    
- **選項與解釋**：
    
    - **Unexpected modifications to files containing sensitive data**：對包含敏感資料的檔案進行了未預期的修改（正確，可能代表資料正在被竊取者打包或更改）。
        
    - ~~Multiple successful multi-factor authentication logins~~：多次成功的多因素驗證登入（這通常是正常的合法使用者行為）。
        
    - **Outbound network traffic to an unauthorized file hosting service**：向未授權的檔案寄存服務發送對外網路流量（正確，這是將機密資料傳出外部常用的手法）。
        
    - ~~Network performance issues~~：網路效能問題（範圍太廣，不一定是資料外洩）。
        
- **正確答案（選兩個）**：
    
    - **Unexpected modifications to files containing sensitive data**
        
    - **Outbound network traffic to an unauthorized file hosting service**
        

### 第 3 個問題

- **英文題目**：Fill in the blank: The transmission of data between devices on a network is governed by a set of standards known as _____.
    
- **中文翻譯**：填空：網路上設備之間資料的傳輸受一組被稱為 _____ 的標準所規範。
    
- **選項**：headers（標頭）、ports（連接埠）、protocols（通訊協定）、payloads（酬載）。
    
- **正確答案**：
    
    - **protocols**（通訊協定）
        

### 第 4 個問題

- **英文題目**：Do packet capture files provide detailed snapshots of network communications?
    
- **中文翻譯**：封包擷取檔（packet capture files）是否提供了網路通訊的詳細快照？
    
- **選項**：
    
    - **Yes. Packet capture files provide information about network data packets that were intercepted from a network interface.**（是。封包擷取檔提供有關從網路介面攔截到的網路資料封包的資訊）
        
    - No. Packet capture files do not contain detailed information about network data packets.（否）
        
    - Maybe. The amount of detailed information packet captures contain depends on the type of network interface that is used.（也許）
        
- **正確答案**：
    
    - **Yes. Packet capture files provide information about network data packets that were intercepted from a network interface.**
        

### 第 5 個問題

- **英文題目**：Fill in the blank: tcpdump is a network protocol analyzer that uses a(n) _____ interface.
    
- **中文翻譯**：填空：tcpdump 是一個使用 _____ 介面的網路通訊協定分析器。
    
- **選項**：graphical user（圖形使用者）、**command-line**（命令列）、Linux、internet。
    
- **正確答案**：
    
    - **command-line**（命令列）
        

### 第 6 個問題

- **英文題目**：Which layer of the TCP/IP model is responsible for accepting and delivering packets in a network?
    
- **中文翻譯**：TCP/IP 模型的哪一個層級負責在網路中接收和傳遞封包？
    
- **選項**：Transport（傳輸層）、Network Access（網路存取層）、**Internet**（網際網路層）、Application（應用程式層）。
    
- **正確答案**：
    
    - **Internet**（網際網路層）
        

### 第 7 個問題

- **英文題目**：What is used to determine whether errors have occurred in the IPv4 header?
    
- **中文翻譯**：用什麼來判定 IPv4 標頭中是否發生了錯誤？
    
- **選項**：Flags（旗標）、**Checksum**（檢驗和）、Protocol（通訊協定）、Header（標頭）。
    
- **正確答案**：
    
    - **Checksum**（檢驗和）
        

### 第 8 個問題

- **英文題目**：Which IPv4 field uses a value to represent a standard, like TCP?
    
- **中文翻譯**：哪一個 IPv4 欄位使用值來表示諸如 TCP 之類的標準／協定？
    
- **選項**：Version（版本）、Type of Service（服務類型）、**Protocol**（通訊協定）、Total Length（總長度）。
    
- **正確答案**：
    
    - **Protocol**（通訊協定）
        

### 第 9 個問題

- **英文題目**：Which tcpdump option applies verbosity?
    
- **中文翻譯**：哪一個 tcpdump 選項用於套用詳細程度（verbosity，即輸出更多詳細資訊）？
    
- **選項**：`-n`、`-i`、**`-v`**（verbose）、`-c`。
    
- **正確答案**：
    
    - **-v**
        

### 第 10 個問題

- **英文題目**：Examine the following tcpdump output: `22:00:19.538395 IP (tos 0x10, ttl 64, id 33842, offset 0, flags [P], proto TCP (6), length 196) 198.168.105.1.41012 > 198.111.123.1.61012: Flags [P.], cksum 0x50af (correct), seq 169, ack 187, win 501, length 42` Which protocols are being used? Select two answers.
    
- **中文翻譯**：檢視下列 tcpdump 輸出，正在使用哪些通訊協定？請選擇兩個答案。
    
- **選項與解釋**：
    
    - **IP**（輸出中有 `IP (...)`）
        
    - **TCP**（輸出中有 `proto TCP (6)` 以及 `Flags [P.]`）
        
    - ~~TOS~~（TOS 欄位是 IP 標頭的一部分，非獨立通訊協定）
        
    - ~~UDP~~（此處使用的是 TCP）
        
- **正確答案（選兩個）**：
    
    - **IP**
        
    - **TCP**

### 第 1 個問題

- **英文題目**：A security analyst is investigating an alert involving a possible network intrusion. Which of the following tasks is the security analyst likely to perform as part of the Detection and Analysis phase of the incident response lifecycle? Select two answers.
    
- **中文翻譯**：安全分析師正在調查涉及可能網路入侵的警報。作為事件應變生命週期中「偵測與分析（Detection and Analysis）」階段的一部分，安全分析師可能會執行下列哪些任務？請選擇兩個答案。
    
- **選項與解釋**：
    
    - ~~Isolate the affected machine from the network.~~：將受影響的機器從網路上隔離（這屬於 Containment 遏制階段，非偵測與分析階段）。
        
    - **Identify the affected devices or systems.**：識別受影響的設備或系統（正確，這屬於分析與確認範圍）。
        
    - ~~Implement a patch to fix the vulnerability.~~：實作修補程式來修復弱點（這屬於 Eradication 根除階段）。
        
    - **Collect and analyze the network logs to verify the alert.**：收集並分析網路日誌以驗證警報（正確，屬於偵測與分析的核心工作）。
        
- **正確答案（選兩個）**：
    
    - **Identify the affected devices or systems.**
        
    - **Collect and analyze the network logs to verify the alert.**
        

### 第 2 個問題

- **英文題目**：In incident response, documentation provides an established set of guidelines that members of an organization can follow to complete a task. What documentation benefit does this provide?
    
- **中文翻譯**：在事件應變中，文件提供了一套組織成員可以遵循以完成任務的既定準則。這提供了什麼文件好處？
    
- **選項**：
    
    - Integrity（完整性）
        
    - Transparency（透明度）
        
    - Reliability（可靠性）
        
    - **Standardization**（標準化）
        
- **正確答案**：
    
    - **Standardization**（標準化）
        

### 第 3 個問題

- **英文題目**：What are examples of how transparent documentation can be useful? Select all that apply.
    
- **中文翻譯**：透明的文件（transparent documentation）有何用處的例子？請選出所有適用選項。
    
- **選項與解釋**：
    
    - ~~Defining an organization's security posture~~：定義組織的安全態勢（這通常由安全政策或架構定義，非透明文件主要用途）。
        
    - **Providing evidence for legal proceedings**：為法律訴訟提供證據（正確，公開透明且合規的文件可作為法庭或調查證據）。
        
    - **Demonstrating compliance with regulatory requirements**：證明符合法規要求（正確，稽核與監管機關需要透明的文件紀錄）。
        
    - **Meeting cybersecurity insurance requirements**：符合網路安全保險的要求（正確，保險公司通常要求提供清楚透明的事件應變與安全紀錄）。
        
- **正確答案（選三個）**：
    
    - **Providing evidence for legal proceedings**
        
    - **Demonstrating compliance with regulatory requirements**
        
    - **Meeting cybersecurity insurance requirements**
        

### 第 4 個問題

- **英文題目**：Chain of custody documents establish proof of which of the following? Select two answers.
    
- **中文翻譯**：監管鏈（Chain of custody）文件確立了下列哪些項目的證明？請選擇兩個答案。
    
- **選項与解釋**：
    
    - **Integrity**：完整性（正確，監管鏈確保證據自採集以來未被篡改）。
        
    - ~~Validation~~：驗證
        
    - ~~Quality~~：品質
        
    - **Reliability**：可靠性（正確，證明證據在法律或鑑識程序中的可信度）。
        
- **正確答案（選兩個）**：
    
    - **Integrity**
        
    - **Reliability**
        

### 第 5 個問題

- **英文題目**：Which of the following does a semi-automated playbook use? Select two.
    
- **中文翻譯**：半自動化腳本（semi-automated playbook）使用下列哪兩項？請選擇兩個。
    
- **選項與解釋**：
    
    - **Human intervention**：人工介入（半自動化代表結合自動化與人工判斷）。
        
    - ~~Crowdsourcing~~：群眾外包
        
    - **Automation**：自動化（結合自動化系統執行部分任務）。
        
    - ~~Threat intelligence~~：威脅情資
        
- **正確答案（選兩個）**：
    
    - **Human intervention**
        
    - **Automation**
        

### 第 6 個問題

- **英文題目**：Using triage, which alert would be considered a higher priority and require immediate response?
    
- **中文翻譯**：透過分類分級（triage），哪一個警報會被認為是較高優先級並需要立即回應？
    
- **選項**：
    
    - Multiple failed logins from multiple locations（來自多個位置的多個登入失敗）
        
    - Failed logins with disabled accounts（使用已停用帳號的登入失敗）
        
    - **Ransomware detection**（偵測到勒索軟體 — 具備高破壞性，需要最高優先級立即處理）
        
    - A phishing email（網路釣魚郵件）
        
- **正確答案**：
    
    - **Ransomware detection**
        

### 第 7 個問題

- **英文題目**：What are the steps of the third phase of the NIST Incident Response Lifecycle? Select three answers.
    
- **中文翻譯**：NIST 事件應變生命週期第三階段（包含遏制、根除與復原）包含哪些步驟？請選擇三個答案。
    
- **選項與解釋**：
    
    - ~~Response~~（回應是整體生命週期或對應框架，非第三階段的子步驟）
        
    - **Containment**：遏制（正確，第三階段 Containment, Eradication, and Recovery 的一部分）
        
    - **Eradication**：根除（正確）
        
    - **Recovery**：復原（正確）
        
- **正確答案（選三個）**：
    
    - **Containment**
        
    - **Eradication**
        
    - **Recovery**
        

### 第 8 個問題

- **英文題目**：Which of the following is an example of a recovery task?
    
- **中文翻譯**：以下哪一項是復原任務（recovery task）的例子？
    
- **選項與解釋**：
    
    - Disconnecting an infected system from the network（從網路斷開受感染的系統 — 這是 Containment 遏制）
        
    - Applying a patch to address a server vulnerability（套用修補程式來處理伺服器弱點 — 這是 Eradication 根除）
        
    - Monitoring a network for intrusions（監控網路是否有入侵 — 這是 Detect 偵測）
        
    - **Reinstalling the operating system of a computer infected by malware**：重新安裝被惡意軟體感染的電腦的作業系統（正確，將系統恢復到乾淨且正常的運作狀態屬於 Recovery 復原）
        
- **正確答案**：
    
    - **Reinstalling the operating system of a computer infected by malware**
        

### 第 9 個問題

- **英文題目**：Two weeks after an incident involving ransomware, the members of an organization want to review the incident in detail. Which of the following actions should be done during this review? Select all that apply.
    
- **中文翻譯**：在發生勒索軟體事件兩週後，組織成員想要詳細檢討該事件。在此檢討期間應採取以下哪些行動？請選出所有適用選項。
    
- **選項與解釋**：
    
    - **Schedule a lessons learned meeting that includes all parties involved with the security incident.**：安排一場包含所有相關人員的經驗教訓（lessons learned）會議（正確）。
        
    - **Determine how to improve future response processes and procedures.**：確定如何改進未來的應變流程與程序（正確）。
        
    - **Create a final report.**：建立最終報告（正確）。
        
    - ~~Determine the person to blame for the incident.~~：判定事件應該怪罪的個人（錯誤，檢討會議的目的是改進流程與防禦，而非進行指責或獵巫 blame game）。
        
- **正確答案（選三個）**：
    
    - **Schedule a lessons learned meeting that includes all parties involved with the security incident.**
        
    - **Determine how to improve future response processes and procedures.**
        
    - **Create a final report.**
        

### 第 10 個問題

- **英文題目**：What does a final report contain? Select three.
    
- **中文翻譯**：最終報告（final report）包含什麼？請選擇三項。
    
- **選項與解釋**：
    
    - **Timeline**：時間軸（事件發生的時間序列，正確）。
        
    - **Recommendations**：建議事項（未來如何預防或改進，正確）。
        
    - **Incident details**：事件詳細資訊（發生了什麼事、受影響範圍等，正確）。
        
    - ~~Updates~~：更新（此處非最終報告的核心組成項目）。
        
- **正確答案（選三個）**：
    
    - **Timeline**
        
    - **Recommendations**
        
    - **Incident details**

### 第 1 個問題

- **英文題目**：Which software collects and sends logs to a security information and event management (SIEM) tool?
    
- **中文翻譯**：哪種軟體會收集日誌並將其發送到安全資訊與事件管理（SIEM）工具？
    
- **選項**：
    
    - Intrusion detection system (IDS)（入侵偵測系統）
        
    - Network protocol analyzer（網路通訊協定分析器）
        
    - **Forwarder**（轉發器 — 負責將收集到的日誌傳送到 SIEM）
        
    - Firewall（防火牆）
        
- **正確答案**：
    
    - **Forwarder**
        

### 第 2 個問題

- **英文題目**：Examine the following log: `LoginEvent[2021/10/13 10:32:08.958711] auth_session_authenticator.cc:304 Regular user login 1` Which type of log is this?
    
- **中文翻譯**：檢查上述日誌，這屬於哪種類型的日誌？
    
- **選項**：
    
    - **Authentication**（驗證日誌 — 包含使用者登入與 `auth_session_authenticator` 相關資訊）
        
    - Application（應用程式日誌）
        
    - Network（網路日誌）
        
    - Location（位置日誌）
        
- **正確答案**：
    
    - **Authentication**
        

### 第 3 個問題

- **英文題目**：Examine the following log:
    
    JSON
    
    ```
    {
    	“name”: “System test”,
    	“host”: "167.155.183.139",
    	“id”: 11111,
    	“Message”: [error] test,
    }
    ```
    
    Which log format is this log entry in?
    
- **中文翻譯**：檢查上述日誌項目，這是採用哪種日誌格式？
    
- **選項**：
    
    - CSV
        
    - Syslog
        
    - XML
        
    - **JSON**（採用大括號與鍵值對 `key: value` 結構）
        
- **正確答案**：
    
    - **JSON**
        

### 第 4 個問題

- **英文題目**：Fill in the blank: _____ analysis is a detection method used to find events of interest using patterns.
    
- **中文翻譯**：填空：_____ 分析是一種使用模式（patterns）來尋找關注事件的偵測方法。
    
- **選項**：
    
    - **Signature**（特徵碼／簽章分析 — 透過既有特徵或模式來比對威脅）
        
    - Network（網路）
        
    - Endpoint（端點）
        
    - Host（主機）
        
- **正確答案**：
    
    - **Signature**
        

### 第 5 個問題

- **英文題目**：What are examples of common rule actions that can be found in signature? Select three answers.
    
- **中文翻譯**：特徵碼（signature）中常見的規則動作（rule actions）有哪些？請選擇三個答案。
    
- **選項與解釋**：
    
    - ~~Flow~~：流量（這屬於選項設定，非規則動作）
        
    - **Pass**：放行（常見規則動作之一）
        
    - **Alert**：警報（常見規則動作之一）
        
    - **Reject**：拒絕／阻斷（常見規則動作之一）
        
- **正確答案（選三個）**：
    
    - **Pass**
        
    - **Alert**
        
    - **Reject**
        

### 第 6 個問題

- **英文題目**：Which symbol is used to indicate a comment and is ignored in a Suricata signature file?
    
- **中文翻譯**：在 Suricata 特徵碼檔案中，哪個符號用於表示註解（comment）並會被忽略？
    
- **選項**：
    
    - **#**（用於單行註解）
        
    - `:`
        
    - `>`
        
    - `$`
        
- **正確答案**：
    
    - **#**
        

### 第 7 個問題

- **英文題目**：Fill in the blank: Suricata uses the _____ format for event and alert output.
    
- **中文翻譯**：填空：Suricata 使用 _____ 格式來輸出事件和警報。
    
- **選項**：
    
    - HTML
        
    - CEF
        
    - HTTP
        
    - **EVE JSON**（Suricata 標準的結構化日誌輸出格式）
        
- **正確答案**：
    
    - **EVE JSON**
        

### 第 8 個問題

- **英文題目**：Which querying language does Splunk use?
    
- **中文翻譯**：Splunk 使用哪一種查詢語言？
    
- **選項**：
    
    - SIEM Processing Language
        
    - Structured Querying Language (SQL)
        
    - Structured Processing Language
        
    - **Search Processing Language (SPL)**（Splunk 專屬的搜尋處理語言）
        
- **正確答案**：
    
    - **Search Processing Language**
        

### 第 9 個問題

- **英文題目**：What is the method to search for normalized data in Chronicle?
    
- **中文翻譯**：在 Chronicle 中搜尋正規化資料的方法是什麼？
    
- **選項**：
    
    - YARA-L（Google Chronicle 用於偵測與檢索的規則語言）
        
    - Unified
        
    - Raw log search（原始日誌搜尋）
        
    - UDM search（Unified Data Model 搜尋， Chronicle 的正規化資料模型）
        
- **正確答案**：
    
    - **UDM search**（或者在 Chronicle 規則層面使用 YARA-L 進行正規化資料檢索；在基礎查詢中 UDM search 是正規化欄位的對應檢索方式。對應常見題庫，此題標準答案為 **UDM search**）。
        

### 第 10 個問題

- **英文題目**：What are the steps in the SIEM process for data collection? Select three answers.
    
- **中文翻譯**：SIEM 資料收集流程中的步驟有哪些？請選擇三個答案。
    
- **選項與解釋**：
    
    - **Normalize**：正規化（將不同格式的日誌轉換為統一格式，正確）
        
    - **Collect**：收集（擷取原始日誌，正確）
        
    - ~~Unify~~：統一（非 SIEM 核心流程標準名詞）
        
    - **Index**：索引（將資料建立索引以便快速搜尋，正確）
        
- **正確答案（選三個）**：
    
    - **Normalize**
        
    - **Collect**
        
    - **Index**


```

## Lesson 7

```
### 第 1 個問題

- **英文題目**：Fill in the blank: Automation is _____.
    
- **中文翻譯**：填空：自動化（Automation）是 _____。
    
- **選項**：
    
    - the combination of technology and manual effort to complete a task（完成任務的技術與人工結合）
        
    - the use of human and manual effort to reduce technological power consumption（使用人工來減少技術功耗）
        
    - the replacement of existing technology（現有技術的替換）
        
    - **the use of technology to reduce human and manual effort to perform common and repetitive tasks**（使用技術來減少執行常見且重複任務時所需的人工與手動努力）
        
- **正確答案**：
    
    - **the use of technology to reduce human and manual effort to perform common and repetitive tasks**
        

### 第 2 個問題

- **英文題目**：What is wrong with the following code?
    
    Python
    
    ```
    for username in failed_login:
    print(username)
    ```
    
- **中文翻譯**：以下程式碼有什麼錯誤？
    
- **選項與解釋**：
    
    - ~~Both lines are not indented.~~
        
    - ~~The line with for username in failed_login: is not indented.~~
        
    - **The line with print(username) is not indented.**：包含 `print(username)` 的行沒有縮排（Python 中迴圈或條件式底下的程式碼區塊必須進行縮排，否則會報錯）。
        
    - ~~The first line should be split in two...~~
        
- **正確答案**：
    
    - **The line with print(username) is not indented.**
        

### 第 3 個問題

- **英文題目**：What data type requires quotation marks (" ")?
    
- **中文翻譯**：哪種資料類型需要引號（" "）？
    
- **選項**：Float（浮點數）、Integer（整數）、Boolean（布林值）、**String**（字串）。
    
- **正確答案**：
    
    - **String**
        

### 第 4 個問題

- **英文題目**：What are possible values for the Boolean data type? Select all that apply.
    
- **中文翻譯**：布林（Boolean）資料類型的可能值有哪些？請選出所有適用選項。
    
- **選項與解釋**：
    
    - `>`（比較運算子，非布林值）
        
    - **True**（布林值：真）
        
    - **False**（布林值：假）
        
    - `!=`（比較運算子，非布林值）
        
- **正確答案（選兩個）**：
    
    - **True**
        
    - **False**
        

### 第 5 個問題

- **英文題目**：What are the variables in the following code? Select all that apply.
    
    Python
    
    ```
    username = "kcarter"
    attempts = 5
    print(username)
    print(attempts)
    print("locked")
    ```
    
- **中文翻譯**：以下程式碼中哪些是變數（variables）？請選出所有適用選項。
    
- **選項與解釋**：
    
    - **username**（變數名稱，正確）
        
    - ~~"kcarter"~~（這是字串值，不是變數）
        
    - ~~"locked"~~（這是字串值，不是變數）
        
    - **attempts**（變數名稱，正確）
        
- **正確答案（選兩個）**：
    
    - **username**
        
    - **attempts**
        

### 第 6 個問題

- **英文題目**：What code can you use to return the data type of the value stored in the input variable?
    
- **中文翻譯**：你可以使用哪段程式碼來回傳儲存在 `input` 變數中的值的資料類型？
    
- **選項**：
    
    - **type(input)**（Python 內建的 `type()` 函數可用於檢查資料型態）
        
    - print("type")
        
    - print(input)
        
    - type("string")
        
- **正確答案**：
    
    - **type(input)**
        

### 第 7 個問題

- **英文題目**：You are implementing security measures on a server. If a user has more than 3 failed login attempts, the program should print "locked out". The number of failed login attempts is stored in a variable called failed_attempts. Which conditional statement has the correct syntax needed to do this?
    
- **中文翻譯**：你正在伺服器上實施安全措施。如果使用者有超過 3 次登入失敗嘗試，程式應該印出 "locked out"。失敗次數儲存在變數 `failed_attempts` 中。哪一個條件式具有正確的語法來達成此目的？
    
- **選項與解釋**：
    
    - ~~if failed_attempts >= 3~~（多於 3 次應為大於 >，且缺少冒號）
        
    - ~~if failed_attempts <= 3:~~（小於等於 3）
        
    - **if failed_attempts > 3:**（大於 3 且結尾帶有正確的冒號 `:`，正確語法）
        
    - ~~if failed_attempts < 3~~（少於 3 且缺少冒號）
        
- **正確答案**：
    
    - **if failed_attempts > 3:**
        

### 第 8 個問題

- **英文題目**：Fill in the blank: An else statement _____.
    
- **中文翻譯**：填空：`else` 陳述式 _____。
    
- **選項**：
    
    - is required after every if statement（在每個 if 陳述式之後都是必需的 — 錯誤，else 是選用的）
        
    - contains its own unique condition（包含其獨特的條件 — 錯誤，else 沒有自己的條件）
        
    - **executes when the condition in the if statement preceding it evaluates to False**（當其前方的 if 陳述式條件評估為 False 時執行）
        
    - executes when the condition in the if statement preceding it evaluates to True（當其前方的 if 陳述式條件評估為 True 時執行）
        
- **正確答案**：
    
    - **executes when the condition in the if statement preceding it evaluates to False**
        

### 第 9 個問題

- **英文題目**：What iterative statement should you use if you want to print the numbers 1, 2, and 3?
    
- **中文翻譯**：如果你想印出數字 1、2 和 3，應該使用哪一個迭代（迴圈）陳述式？
    
- **選項與解釋**：
    
    - ~~for i in range(0,3):~~（會產生 0, 1, 2）
        
    - ~~for i in [1,3]:~~（只會產生 1 和 3）
        
    - ~~for i in range(1,3):~~（會產生 1, 2，少了一個 3）
        
    - **for i in range(1,4):**（`range(1, 4)` 的範圍是從 1 開始到小於 4 為止，會產生 1, 2, 3，正確）
        
- **正確答案**：
    
    - **for i in range(1,4):**
        

### 第 10 個問題

- **英文題目**：You want to print all even numbers between 0 and 10 (in other words, 0, 2, 4, 6, 8, and 10). What should your next line of code be?
    
    Python
    
    ```
    count = 0
    while count <= 10:
        print(count)
        # 這裡應該填入什麼？
    ```
    
- **中文翻譯**：你想要印出 0 到 10 之間的所有偶數（亦即 0, 2, 4, 6, 8 和 10）。你的下一行程式碼應該是什麼？
    
- **選項與解釋**：
    
    - ~~if count < 10:~~
        
    - ~~count = count + 1~~（這樣會變成遞增 1，無法印出偶數序列）
        
    - ~~count = 1~~
        
    - **count = count + 2**（每次迴圈將 `count` 增加 2，才能依序產生 0, 2, 4, 6, 8, 10，正確）
        
- **正確答案**：
    
    - **count = count + 2**


### 第 1 個問題

- **英文題目**：Which of the following components are part of the header in a function definition? Select all that apply.
    
- **中文翻譯**：以下哪些元件是函式定義中標頭（header）的一部分？請選出所有適用選項。
    
- **選項與解釋**：
    
    - **The name of the function**：函式名稱（正確）
        
    - **The keyword def**：`def` 關鍵字（正確，用於定義函式）
        
    - **The parameters used in a function**：函式中使用的參數（正確，寫在標頭的括號內）
        
    - ~~The keyword return~~：`return` 關鍵字（錯誤，這是函式主體 body 內的敘述，非標頭部分）
        
- **正確答案（選三個）**：
    
    - **The name of the function**
        
    - **The keyword def**
        
    - **The parameters used in a function**
        

### 第 2 個問題

- **英文題目**：Which of the following components are needed to call a built-in function in Python? Select three answers.
    
- **中文翻譯**：在 Python 中呼叫內建函式需要哪些元件？請選擇三個答案。
    
- **選項與解釋**：
    
    - ~~`:`~~：冒號（錯誤，用於定義語句如 if 或 def，不是呼叫函式必需的）
        
    - **The function name**：函式名稱（正確）
        
    - **`()`**：括號（正確，呼叫函式時必須帶有括號）
        
    - **The arguments required by the function**：函式所需的引數（正確，放入括號內傳遞）
        
- **正確答案（選三個）**：
    
    - **The function name**
        
    - **`()`**
        
    - **The arguments required by the function**
        

### 第 3 個問題

- **英文題目**：Review the following code. Which of these statements accurately describes `name`?
    
    Python
    
    ```
    def echo(name):
        return name * 3
    ```
    
- **中文翻譯**：檢閱以下程式碼。以下哪一項敘述準確描述了 `name`？
    
- **選項與解釋**：
    
    - It is an argument because it is included in the function call.（它是引數，因為它包含在函式呼叫中）
        
    - It is a parameter because it is used in a return statement.（它是參數，因為它用於 return 陳述式中）
        
    - **It is a parameter because it is included in the function definition.**：它是參數（parameter），因為它包含在函式定義（definition）中（正確）。
        
    - It is an argument because it is used in a return statement.（它是引數，因為它用於 return 陳述式中）
        
- **正確答案**：
    
    - **It is a parameter because it is included in the function definition.**
        

### 第 4 個問題

- **英文題目**：When working in Python, what is a library?
    
- **中文翻譯**：在 Python 中工作時，什麼是程式庫（library）？
    
- **選項**：
    
    - A Python file that contains additional functions, variables, classes, and any kind of runnable code（這是模組 module 的定義）
        
    - A collection of stylistic guidelines for working with Python（這是風格指南的定義）
        
    - **A collection of modules that provide code users can access in their programs**：提供使用者可以在其程式中存取之程式碼的模組集合（正確，程式庫通常包含多個模組）
        
    - A module that allows you to work with a particular type of file
        
- **正確答案**：
    
    - **A collection of modules that provide code users can access in their programs**
        

### 第 5 個問題

- **英文題目**：What does this line of code return?
    
    Python
    
    ```
    print(type("h32rb17"))
    ```
    
- **中文翻譯**：這行程式碼會回傳什麼？
    
- **選項**：int、h32rb17、"h32rb17"、**str**。
    
- **正確答案**：
    
    - **str**（因為 `"h32rb17"` 是一個字串 string）
        

### 第 6 個問題

- **英文題目**：What is returned from the following user-defined function if you pass it the argument of 2?
    
    Python
    
    ```
    def multiples(num):
        multiple = num * 3
        return multiple
    multiples(2)
    ```
    
- **中文翻譯**：如果您將引數 2 傳遞給以下自訂函式，它會回傳什麼？
    
- **選項**：num、multiples、**6**、2。
    
- **正確答案**：
    
    - **6**（`2 * 3 = 6`）
        

### 第 7 個問題

- **英文題目**：Which of the following choices is a resource that provides stylistic guidelines for programmers working in Python?
    
- **中文翻譯**：以下哪一項是為在 Python 中工作的程式設計師提供風格指南（stylistic guidelines）的資源？
    
- **選項**：re、glob、Python Standard Library、**PEP 8**。
    
- **正確答案**：
    
    - **PEP 8**（Python 官方程式碼風格指南）
        

### 第 8 個問題

- **英文題目**：Why are comments useful? Select three answers.
    
- **中文翻譯**：為什麼註解（comments）很有用？請選擇三個答案。
    
- **選項與解釋**：
    
    - **They make debugging easier later on.**：它們讓以後的除錯更容易（正確）。
        
    - ~~They make the code run faster.~~：它們讓程式碼運行得更快（錯誤，註解會被直譯器忽略，不會加速執行）。
        
    - **They explain the code to other programmers.**：它們向其他程式設計師解釋程式碼（正確）。
        
    - **They provide insight on what the code does.**：它們提供了對程式碼功用的見解（正確）。
        
- **正確答案（選三個）**：
    
    - **They make debugging easier later on.**
        
    - **They explain the code to other programmers.**
        
    - **They provide insight on what the code does.**
        

### 第 9 個問題

- **英文題目**：What are built-in functions?
    
- **中文翻譯**：什麼是內建函式（built-in functions）？
    
- **選項**：
    
    - Functions that return information（會回傳資訊的函式）
        
    - **Functions that exist with Python and can be called directly**：存在於 Python 中且可以直接呼叫的函式（正確）
        
    - Functions that take parameters（接受參數的函式）
        
    - Functions that a programmer builds for their specific needs（程式設計師為其特定需求而建立的函式）
        
- **正確答案**：
    
    - **Functions that exist with Python and can be called directly**
        

### 第 10 個問題

- **英文題目**：Fill in the blank: A Python file that contains additional functions, variables, classes, and any kind of runnable code is called a _____.
    
- **中文翻譯**：填空：包含額外函式、變數、類別以及任何可執行程式碼的 Python 檔案被稱為 _____。
    
- **選項**：library、parameter、built-in function、**module**。
    
- **正確答案**：
    
    - **module**（模組）

### 第 1 個問題

- **英文題目**：Which line of code returns the number of characters in the string assigned to the `username` variable?
    
- **中文翻譯**：哪一行程式碼會回傳指派給 `username` 變數的字串中的字元數（即字串長度）？
    
- **選項**：
    
    - print(str(username))
        
    - print(username.str())
        
    - **print(len(username))**（使用內建的 `len()` 函數來計算字串長度）
        
    - print(username.len())
        
- **正確答案**：
    
    - **print(len(username))**
        

### 第 2 個問題

- **英文題目**：Which line of code returns a copy of the string "bmoreno" as "BMORENO"?
    
- **中文翻譯**：哪一行程式碼會將字串 "bmoreno" 複製並轉換為大寫的 "BMORENO"？
    
- **選項**：
    
    - print("bmoreno"(upper))
        
    - print(upper."bmoreno"())
        
    - print(upper("bmoreno"))
        
    - **print("bmoreno".upper())**（使用字串方法 `.upper()` 將字串全部轉為大寫）
        
- **正確答案**：
    
    - **print("bmoreno".upper())**
        

### 第 3 個問題

- **英文題目**：In the string "network", which character has an index of 1?
    
- **中文翻譯**：在字串 "network" 中，哪一個字元的索引（index）是 1？
    
- **選項與解釋**：
    
    - 在 Python 中，字串索引從 0 開始：
        
        - `n` 的索引是 0
            
        - **`e` 的索引是 1**
            
        - `t` 的索引是 2
            
        - `w` 的索引是 3...以此類推。
            
    - **"e"**
        
- **正確答案**：
    
    - **"e"**
        


        

### 第 5 個問題

- **英文題目**：Which code joins a list of `new_users` to a list of `approved_users` and assigns the value to a third variable named `users`?
    
- **中文翻譯**：哪一段程式碼可以將 `new_users` 列表與 `approved_users` 列表串接（合併），並將結果指派給第三個名為 `users` 的變數？
    
- **選項**：
    
    - users(new_users, approved_users)
        
    - users(new_users[1], approved_users[2])
        
    - **users = new_users + approved_users**（在 Python 中，可以使用 `+` 運算子將兩個列表合併）
        
    - users = insert(new_users, approved_users)
        
- **正確答案**：
    
    - **users = new_users + approved_users**
        

### 第 6 個問題

- **英文題目**：A variable named `my_list` contains the list [1,2,3,4]. Which line of code adds the element 5 to the end of the list?
    
- **中文翻譯**：一個名為 `my_list` 的變數包含列表 `[1, 2, 3, 4]`。哪一行程式碼可以將元素 `5` 新增到該列表的「結尾」？
    
- **選項與解釋**：
    
    - _注意：標準 Python 新增至結尾的方法是 `append(5)`，但在測驗題庫的這類題目中，若選項提供的是 `insert` 或類似語法，通常考查的是索引位置。列表最後一個元素 4 的索引是 3，若要在其後面加入 5，則使用插入到索引 4 的位置：`my_list.insert(4, 5)`（將 5 插入到 index 4，即排在最後）_。
        
    - my_list.insert(5,5)
        
    - my_list.insert(5,4)
        
    - my_list.insert(5)
        
    - **my_list.insert(4,5)**
        
- **正確答案**：
    
    - **my_list.insert(4,5)**
        

### 第 7 個問題

- **英文題目**：Fill in the blank: Determining that you need to use string slicing and a for loop to extract information from items in a list is part of creating a(n) _____.
    
- **中文翻譯**：填空：確定你需要使用字串切片和 for 迴圈來從列表中的項目提取資訊，這是創建 _____ 的一部分。
    
- **選項**：
    
    - regular expression（正規表達式）
        
    - **algorithm**（演算法 — 規劃解決問題的步驟與邏輯流程）
        
    - append
        
    - index
        
- **正確答案**：
    
    - **algorithm**
        

### 第 8 個問題

- **英文題目**：Which of the following strings would Python return as matches to the regular expression of `"\w+"`? Select all that apply.
    
- **中文翻譯**：對於正規表達式 `"\w+"`（代表一個或多個字元，包含大小寫字母、數字或底線），Python 會將以下哪些字串視為符合匹配？請選出所有適用選項。
    
- **選項與解釋**：
    
    - **"email@email.com"**（其中 `@` 雖然不屬於 `\w`，但 `email` 部分會被匹配到，或者在多數字串中整體視為符合匹配）
        
    - **"9210"**（全部由數字組成，符合 `\w+`）
        
    - **"email123"**（由字母與數字組成，符合 `\w+`）
        
    - **"network"**（全部由字母組成，符合 `\w+`）
        
    - _提示：在多選題庫中，這四個選項全數符合正規表達式 `\w+` 的匹配範圍（因為每個字串都包含至少一個以上的英文字母或數字）。_
        
- **正確答案（選全部）**：
    
        
    - **"9210"**
        
    - **"email123"**
        
    - **"network"**
        

### 第 9 個問題

- **英文題目**：What module do you need to import to use regular expressions in Python?
    
- **中文翻譯**：在 Python 中使用正規表達式需要匯入哪一個模組？
    
- **選項**：time、**re**（Regular Expression 模組）、csv、os。
    
- **正確答案**：
    
    - **re**
        

### 第 10 個問題

- **英文題目**：What does the code `device_ids.append("h32rb17")` do?
    
- **中文翻譯**：程式碼 `device_ids.append("h32rb17")` 的作用是什麼？
    
- **選項**：
    
    - Inserts "h32rb17" at the beginning of the device_ids list（在開頭插入 — 這是 `insert(0, ...)`）
        
    - Updates all instances of "h32rb17"...（更新為大寫）
        
    - **Adds "h32rb17" to the end of the device_ids list**（將 `"h32rb17"` 新增到 `device_ids` 列表的結尾）
        
    - Returns all matches...（回傳符合的匹配項）
        
- **正確答案**：
    
    - **Adds "h32rb17" to the end of the device_ids list**

### 第 1 個問題

- **英文題目**：What is debugging?
    
- **中文翻譯**：什麼是除錯（debugging）？
    
- **選項**：
    
    - The practice of improving code readability.（提高程式碼可讀性的做法）
        
    - **The practice of identifying and fixing errors in code.**（識別並修正程式碼中錯誤的做法，正確）
        
    - The practice of improving code efficiency.（提高程式碼效率的做法）
        
    - The practice of calling a function from multiple places in a larger program
        
- **正確答案**：
    
    - **The practice of identifying and fixing errors in code.**
        

### 第 2 個問題

- **英文題目**：The purpose of the following code is to print the characters in a device ID. Run this code, analyze its output, and then debug it. `device_id = "p35rv47` `for char in device_id:` `print(char)` What is the error related to?
    
- **中文翻譯**：上述程式碼的目的是印出裝置 ID 中的字元。執行此程式碼並除錯，該錯誤與下列何者有關？
    
- **選項與解釋**：
    
    - A missing double equals sign (==)
        
    - A missing colon (:)
        
    - A misspelled variable
        
    - **A missing quotation mark (")**：缺少雙引號（在 `"p35rv47` 的結尾少了一個封閉的雙引號 `"`，導致語法錯誤）。
        
- **正確答案**：
    
    - **A missing quotation mark (")**
        

### 第 3 個問題

- **英文題目**：The purpose of the following code is to iterate through a list and print a warning message if it finds "user3" in the list. Run this code, analyze its output, and debug it.
    
    Python
    
    ```
    list = ["user1", "user2", "user3", "user4"]
    for user in list:
        if user != "user3":
            print("Warning: user3 should not access the system.")
    ```
    
    How can you fix the error?
    
- **中文翻譯**：上述程式碼的目的是走訪列表，如果找到 `"user3"` 就印出警告訊息。如何修正該錯誤？
    
- **選項與解釋**：
    
    - Change the indentation...
        
    - Change "user3" to "user1" in the conditional.
        
    - **Change the != operator to the == operator in the conditional.**：將條件式中的 `!=` 運算子改為 `==`（因為原本的邏輯是當「不等於 user3」時才印出警告，若要找尋並針對 user3 發出警告，必須用等於 `==`）。
        
    - Change "user3" to "user2" in the conditional.
        
- **正確答案**：
    
    - **Change the != operator to the == operator in the conditional.**
        

### 第 4 個問題

- **英文題目**：You ask your code to divide something by 0, but an error occurs. What type of error is this?
    
- **中文翻譯**：你要求程式碼將某個數除以 0，結果發生了錯誤。這是哪種類型的錯誤？
    
- **選項**：Syntax error（語法錯誤）、Logic error（邏輯錯誤）、Index out_of_bounds（索引超出範圍）、**Exception**（異常／執行期錯誤）。
    
- **正確答案**：
    
    - **Exception**
        

### 第 5 個問題

- **英文題目**：When debugging code, what are effective ways to determine which sections of code are working properly? Select all that apply.
    
- **中文翻譯**：在對程式碼進行除錯時，確定哪些程式碼段落運作正常的有效方法有哪些？請選出所有適用選項。
    
- **選項與解釋**：
    
    - **Add print statements**：新增 print 陳述式（正確，透過印出變數值來追蹤狀態）。
        
    - ~~Delete blank lines from the code~~：從程式碼中刪除空白行（無助於除錯）。
        
    - **Use a debugger**：使用除錯器（正確）。
        
    - **Add comments in the code**：在程式碼中新增註解（正確，有助於理清邏輯與標記區段，雖然主要用於說明，但在廣義排查與結構梳理上有幫助。在多選題庫中通常勾選新增 print、使用除錯器與新增註解）。
        
    - _註：標準多選題答案通常包含：Add print statements、Use a debugger、Add comments in the code。_
        
- **正確答案（選三個）**：
    
    - **Add print statements**
        
    - **Use a debugger**
        
   
        

### 第 6 個問題

- **英文題目**：If you want to read a file called "logs.txt", which line of code allows you to open this file for purposes of reading it and store it in a variable called file?
    
- **中文翻譯**：如果您想讀取一個名為 `"logs.txt"` 的檔案，哪一行程式碼允許您以讀取模式開啟該檔案，並將其儲存到名為 `file` 的變數中？
    
- **選項**：
    
    - with file.open("logs.txt", "r"):
        
    - **with open("logs.txt", "r") as file:**（標準 Python 檔案開啟語法）
        
    - with open("logs.txt", file, "r"):
        
    - with open(file, "r") as logs.txt:
        
- **正確答案**：
    
    - **with open("logs.txt", "r") as file:**
        

### 第 7 個問題

- **英文題目**：The `logins` variable is a string containing 20 device IDs. The device IDs are separated by spaces. In order to pass it into a function that checks the login count of each device, the string should be divided into a list of separate IDs. How do you convert this string into a list and store it in a `device_ids` variable?
    
- **中文翻譯**：`logins` 變數是一個包含 20 個裝置 ID 的字串，各 ID 之間以空格分隔。為了將其傳入檢查登入次數的函式，必須將該字串分割成個別 ID 的列表。如何將此字串轉換為列表並儲存到 `device_ids` 變數中？
    
- **選項**：
    
    - **device_ids = logins.split()**（使用 `.split()` 方法預設會以空白字元分割字串並回傳列表）
        
    - logins.split() as device_ids
        
    - device_ids = split(device_ids, logins)
        
    - device_ids = device_ids.split(logins)
        
- **正確答案**：
    
    - **device_ids = logins.split()**
        

### 第 8 個問題

- **英文題目**：What is the process of converting data into a more readable format?
    
- **中文翻譯**：將資料轉換為更容易閱讀的格式的過程是什麼？
    
- **選項**：Slicing（切片）、Debugging（除錯）、Splitting（分割）、**Parsing**（解析）。
    
- **正確答案**：
    
    - **Parsing**（解析）
        

### 第 9 個問題

- **英文題目**：What does the following code do?
    
    Python
    
    ```
    read_text = text.read()
    ```
    
- **中文翻譯**：以下程式碼的作用是什麼？
    
- **選項**：
    
    - Replaces the contents...
        
    - Splits the text variable...
        
    - **Reads the text variable, which contains a file, and stores it as a string in read_text**：讀取包含檔案的 `text` 變數，並將其作為字串儲存到 `read_text` 中。
        
    - Reads the string text...
        
- **正確答案**：
    
    - **Reads the text variable, which contains a file, and stores it as a string in read_text**
        

### 第 10 個問題

- **英文題目**：You want to check if a device is running a particular operating system that needs updates. Devices that contain a substring of "i71" in their device ID are running this operating system. First, you want to read in a log file that contains the device ID for all devices and convert it into a string. You should then parse this string into a devices list. Then, you should separate all device IDs that contain the substring "i71" into a separate list called updates_list. If you want to automate this through Python, what would be part of your code? Select three answers.
    
- **中文翻譯**：您想要檢查設備是否正在運行需要更新的特定作業系統。設備 ID 中包含子字串 `"i71"` 的設備正在運行該作業系統。首先，您想要讀入包含所有設備 ID 的日誌檔並將其轉換為字串。然後，您應該將此字串解析為 `devices` 列表。接著，您應該將所有包含子字串 `"i71"` 的設備 ID 分離到一個名為 `updates_list` 的獨立列表中。如果您想透過 Python 自動化此過程，您的程式碼會包含哪些部分？請選擇三個答案。
    
- **選項與解釋**：
    
    - ~~A counter variable to keep track...~~（計數器變數非本任務核心必要項）
        
    - **An if statement that checks if elements in devices contain the substring "i71"**：用於檢查 `devices` 中的元素是否包含子字串 `"i71"` 的 if 陳述式（正確，用於篩選）。
        
    - **A for loop to iterate through all items in the devices list**：用於走訪 `devices` 列表中所有項目的 for 迴圈（正確，用於逐一檢查）。
        
    - **A split() function to split the string containing the information in the log file into a devices list**：用於將包含日誌檔資訊的字串分割成 `devices` 列表的 `.split()` 函式（正確）。
        
- **正確答案（選三個）**：
    
    - **An if statement that checks if elements in devices contain the substring "i71"**
        
    - **A for loop to iterate through all items in the devices list**
        
    - **A split() function to split the string containing the information in the log file into a devices list**


```