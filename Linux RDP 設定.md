---
title: Linux RDP 遠端桌面完整部署教學
toc: true
date: 2026-10-12
---

> 適用環境：Ubuntu 24.04 LTS 以上、Rocky Linux 9 / 10、GNOME Desktop、Proxmox VE / VMware ESXi 虛擬機  
> 最後更新：2026-10-12  
> 主題：RDP Server 部署、遠端登入、Firewall 設定、NLA 驗證、黑畫面排查與效能調校

## 1. 前言

Linux 遠端桌面常見的方式包含 RDP、VNC 與 SSH X11 Forwarding。

其中 RDP（Remote Desktop Protocol）是 Microsoft 制定的遠端桌面協定，可以讓 Windows 使用內建的 `mstsc` 直接連線到 Linux 圖形桌面。

## 目前 Linux 遠端桌面方案比較

| 技術                        | 日常桌面 | 影片／動畫 | GPU 支援      | 適合用途         |
| ------------------------- | ---- | ----- | ----------- | ------------ |
| GNOME Remote Desktop（RDP） | 很好   | 中～好   | 視環境而定       | GNOME 遠端管理   |
| xrdp + Xorg               | 好    | 普通    | 通常有限        | 伺服器、獨立登入工作階段 |
| KDE Plasma + KRdp         | 好    | 中～好   | Wayland 合成器 | KDE 遠端桌面     |
| Sunshine + Moonlight      | 很好   | 很好    | 強，支援硬體編碼    | 高流暢度桌面、影音、遊戲 |
| 傳統 VNC                    | 普通   | 較弱    | 視實作而定       | 簡單管理         |
    
本文將分別介紹兩種方案。
## 2. GNOME Remote Desktop 與 xrdp 比較
## 一、GNOME 有兩種 RDP 模式

| 功能            | Remote Login | Desktop Sharing |
| ------------- | ------------ | --------------- |
| 無人登入時連線       | 支援           | 通常不支援           |
| 顯示 GNOME 登入畫面 |              | 不支援             |
| 獨立遠端工作階段      | 支援           | 分享現有桌面          |
| 預設 Port       | 3389         | 3389 或 3390     |
| 適合用途          | 遠端 Linux 工作站 | 遠端協助            |


|項目|GNOME Remote Desktop|xrdp|
|---|---|---|
|開發專案|GNOME|Neutrinolabs|
|RDP 協定|支援|支援|
|GNOME 整合|原生|依工作階段配置|
|Wayland|原生整合|傳統 xrdp 主要使用 Xorg|
|Xorg|不以此作為新式 Remote Login 的主要後端|常用|
|GDM 遠端登入|支援，依 GNOME 版本|使用 xrdp 自身登入流程|
|適用環境|Ubuntu 24.04+、Rocky Linux 10|Ubuntu、Rocky Linux 9 等|
|Windows mstsc|支援|支援|

**建議：**
如果使用較新的 GNOME，優先考慮 GNOME Remote Desktop。
如果使用 Rocky Linux 9、較舊的 GNOME，或希望搭配 XFCE 建立遠端桌面，則可以選擇 xrdp。

---

# Part 1：GNOME 原生 RDP Server

## 3. GNOME Remote Desktop 運作原理

GNOME Remote Desktop 有兩種主要操作模式。

### 3.1 Desktop Sharing

Desktop Sharing 用來分享目前已經登入的 GNOME 桌面。

特性：
- 共享目前的桌面工作階段。
- 通常需要使用者已登入 GNOME。
- 適合遠端協助與桌面操作。
- 使用 User-level systemd service。
    
### 3.2 Remote Login

Remote Login 可以在使用者尚未登入桌面時，透過 RDP 連線到 GDM 登入畫面。
特性：
- 不需要先登入實體桌面。
- 透過 GDM 建立遠端登入工作階段。
- 支援不同 Linux 使用者登入。
- 使用 System-level systemd service。
- 需要兩階段身分驗證。
    

### 3.3 Remote Login 登入流程

```
Windows mstsc / Linux Remmina
              |
              | TCP 3389
              v
GNOME Remote Desktop
              |
              | 第一階段
              | RDP 帳號密碼驗證
              v
         NLA / TLS
              |
              v
             GDM
              |
              | 第二階段
              | Linux 使用者登入
              v
       GNOME Wayland Session
              |
              v
         GNOME Desktop
```

**重要：RDP 登入帳密不一定等於 Linux 系統使用者帳密。**

第一階段使用 GNOME Remote Login 設定的 Login Details。
第二階段才是 GDM 的 Linux 使用者帳號與密碼。

## 4. Ubuntu 安裝 GNOME Remote Desktop

### 4.1 確認系統版本

```
cat /etc/os-release
gnome-shell --version
```

GNOME 46 開始提供整合 GDM 的 Remote Login 功能，Ubuntu 24.04 LTS 已包含此功能。

### 4.2 安裝必要套件

如果已經安裝 Ubuntu Desktop，通常已有部分套件。
```
sudo apt update
sudo apt install -y \
  gnome-remote-desktop \
  gdm3
```

確認套件：
```
dpkg -l | grep -E 'gnome-remote-desktop|gdm3'
```

如果系統尚未安裝 GNOME 桌面，必須先安裝適當的桌面環境。單獨安裝 RDP 套件不會自動建立完整 GNOME Desktop。

### 4.3 開啟 Remote Login

在 Ubuntu GNOME：
**Settings → System → Remote Desktop → Remote Login**

依序操作：

1. 點擊 Unlock，輸入管理員密碼。
2. 開啟 Remote Login。
3. 在 Login Details 設定 RDP 使用者名稱與密碼。
4. 確認顯示的連線 Port。
    
### 4.4 確認 RDP 狀態
```
cmdkey /delete:TERMSRV/192.168.8.45
```

```
sudo grdctl --system status
systemctl status gnome-remote-desktop.service
ss -lntp | grep -E '3389|3390'
journalctl -u gnome-remote-desktop.service -n 50 --no-pager
journalctl -kf gnome-remote-desktop.servic

##建立rdp密碼
sudo grdctl --system rdp set-credentials testuser '你的測試密碼'
systemctl restart gnome-remote-desktop.service
systemctl daemon-reload
```

| 日誌訊息                             | 可能原因             |
| -------------------------------- | ---------------- |
| `nla_recv() error: -1`           | NLA/CredSSP 握手失敗 |
| `client authentication failure`  | 帳密錯誤或驗證協定問題      |
| `BIO_new failed for certificate` | TLS 憑證路徑或讀取權限問題  |
| `Failed to start remote session` | GDM 或桌面工作階段啟動失敗  |

```
Rocky linux 放行3389
sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload
```


檢查 systemd：

```
sudo systemctl status \
  gnome-remote-desktop.service
```

查看服務是否監聽：

```
sudo ss -lntp | grep -E '3389|3390'
```

如果是 Remote Login，應檢查系統層級服務。

如果是 Desktop Sharing，則檢查目前 GNOME 使用者的服務：

```
systemctl --user status \
  gnome-remote-desktop.service
```

**注意：**`**sudo systemctl**` **與** `**systemctl --user**` **是不同的 systemd 服務管理範圍，不能混為一談。**

## 5. 使用 grdctl 管理 RDP

`grdctl` 是 GNOME Remote Desktop 的命令列管理工具。

### 5.1 查看系統層級設定

```
sudo grdctl --system status
```

### 5.2 啟用 Remote Login RDP

```
sudo grdctl --system rdp enable
```

確認 GDM 與 RDP Service 已啟動：

```
sudo systemctl enable --now \
  gnome-remote-desktop.service
```

```
sudo systemctl status gdm3
```

### 5.3 設定帳號密碼

建議優先使用 GNOME Settings 的 Login Details 設定。

若使用命令列：

```
grdctl --help
```

```
grdctl --system rdp --help
```

不同 GNOME 版本的 `set-credentials` 參數及互動式輸入方式可能不同，請以目前安裝版本的說明為準。

部分版本支援互動式設定：

```
sudo grdctl --system rdp set-credentials
```

不建議直接把真實密碼寫在 Shell 指令中，避免留存在 Shell History 或系統日誌。

### 5.4 停用 Remote Login

```
sudo grdctl --system rdp disable
```

### 5.5 TLS 憑證

GNOME Remote Desktop 使用 TLS 保護連線。

如果透過 GNOME Settings 設定，通常不需要自行產生憑證。

如果透過命令列手動部署，則可能需要使用：

```
sudo grdctl --system rdp set-tls-cert \
  /path/to/tls.crt
```

```
sudo grdctl --system rdp set-tls-key \
  /path/to/tls.key
```

TLS 私鑰必須能被 GNOME Remote Desktop 服務帳號讀取，並應限制其他使用者存取。

---

# Part 2：Rocky Linux RDP

## 6. Rocky Linux 版本差異

Rocky Linux 9 與 Rocky Linux 10 的 GNOME 遠端桌面支援不同。

|版本|建議方案|
|---|---|
|Rocky Linux 9|xrdp + Xorg|
|Rocky Linux 10|GNOME Remote Desktop|
|Ubuntu 24.04+|GNOME Remote Desktop|

Rocky Linux 10 官方已將 GNOME Remote Desktop 作為桌面共享、遠端登入與 Headless Session 的主要方案。
Rocky Linux 9 則可以參考官方 xrdp 教學。

## 7. Rocky Linux 10：GNOME Remote Login

確認 GNOME 版本：

```
gnome-shell --version
```

確認套件：

```
rpm -q gnome-remote-desktop gdm
```

若尚未安裝：

```
sudo dnf install -y \
  gnome-remote-desktop \
  gdm
```

如果系統沒有 GNOME Desktop，應先安裝適合的 GUI 套件群組。

進入 GNOME：

**Settings → System → Remote Desktop → Remote Login**

啟用後確認：

```
sudo grdctl --system status
```

```
sudo systemctl status \
  gnome-remote-desktop.service
```

### 7.1 Rocky Linux 防火牆設定

Rocky Linux 使用 firewalld。

確認狀態：

```
sudo systemctl status firewalld
```

查看目前啟用的 Zone：

```
sudo firewall-cmd --get-active-zones
```

確認網路介面所屬 Zone 後，放行 RDP：

```
sudo firewall-cmd --permanent \
  --add-service=rdp
```

```
sudo firewall-cmd --reload
```

如果服務定義不存在，也可以直接放行 TCP 3389：

```
sudo firewall-cmd --permanent \
  --add-port=3389/tcp
```

```
sudo firewall-cmd --reload
```

檢查規則：

```
sudo firewall-cmd --list-all
```

```
sudo firewall-cmd --query-port=3389/tcp
```

注意：以上未指定 Zone 的指令使用預設 Zone。如果實際網卡位於其他 Zone，必須針對正確 Zone 設定。

如果 GNOME Remote Desktop 使用的不是 3389，應依實際監聽 Port 調整防火牆。

### 7.2 SELinux 注意事項

Rocky Linux 預設可能啟用 SELinux。

查看：

```
getenforce
```

如果 RDP 無法建立工作階段，先檢查 SELinux AVC Denial：

```
sudo ausearch -m AVC -ts recent
```

不要直接永久關閉 SELinux。應先確認是否真的有相關拒絕紀錄，再針對原因處理。

---

# Part 3：xrdp 部署

## 8. Ubuntu 安裝 xrdp

如果不想使用 GNOME 原生 Remote Login，可以選擇 xrdp。

以下以 XFCE 桌面作為範例。

### 8.1 安裝套件

```
sudo apt update
```

```
sudo apt install -y \
  xrdp \
  xorgxrdp \
  xfce4 \
  xfce4-terminal \
  dbus-x11
```

### 8.2 設定遠端桌面工作階段

請以準備透過 RDP 登入的普通 Linux 使用者執行：

```
printf 'exec startxfce4\n' > ~/.xsession
```

不要使用 root 帳號建立一般使用者的 `.xsession`。

### 8.3 啟動 xrdp

```
sudo systemctl enable --now xrdp
```

檢查：

```
sudo systemctl status xrdp
```

確認 Port：

```
sudo ss -lntp | grep 3389
```

### 8.4 Ubuntu UFW 防火牆

如果 UFW 已啟用，可只允許管理網段存取：

```
sudo ufw allow from 192.168.8.0/24 \
  to any port 3389 proto tcp
```

確認：

```
sudo ufw status verbose
```

如果 UFW 沒有啟用，不需要為了 RDP 特別啟用它，但仍須確認其他防火牆或上游 ACL。

### 8.5 Windows 連線

在 Windows 執行：

```
mstsc
```

輸入 Linux IP：

```
192.168.8.45:3389
```

出現 xrdp 登入畫面後，選擇 Xorg 工作階段，輸入 Linux 使用者帳號密碼。

## 9. Rocky Linux 9 安裝 xrdp

Rocky Linux 9 可以透過 EPEL 安裝 xrdp。

### 9.1 啟用 CRB 與 EPEL

```
sudo dnf config-manager --set-enabled crb
```

```
sudo dnf install -y epel-release
```

如果 `config-manager` 不存在，先安裝對應的 DNF Plugin。

### 9.2 安裝 xrdp

```
sudo dnf install -y xrdp
```

依需要確認 Xorg 工作階段相關套件已安裝。

### 9.3 啟動服務

```
sudo systemctl enable --now xrdp
```

### 9.4 放行防火牆

```
sudo firewall-cmd --permanent \
  --add-service=rdp
```

```
sudo firewall-cmd --reload
```

### 9.5 檢查

```
sudo systemctl status xrdp
```

```
sudo ss -lntp | grep 3389
```

如果登入後黑畫面，應先確認 Xorg 工作階段、使用者登入狀態及 xrdp 日誌。

---

# Part 4：Windows、Linux、macOS 連線方式

## 10. Windows RDP Client

Windows 內建 Remote Desktop Connection。

開啟：

```
mstsc
```

輸入：

```
192.168.8.45:3389
```

如果使用 GNOME Remote Login：

1. 輸入 GNOME 設定的 RDP 帳號密碼。
    
2. 通過 NLA 驗證。
    
3. 進入 GDM。
    
4. 輸入 Linux 使用者帳號密碼。
    

如果使用 xrdp，通常會進入 xrdp 的登入介面。

## 11. Linux RDP Client

Linux 可以使用 Remmina：

Ubuntu：

```
sudo apt install -y remmina
```

Rocky Linux 則依套件庫或 Flatpak 提供情況安裝。

Remmina 新增連線時：

- Protocol：RDP
    
- Server：Linux RDP Server IP
    
- Port：3389 或實際設定 Port
    
- Username / Password：依 RDP Server 模式設定
    

## 12. macOS RDP Client

macOS 可以安裝 Microsoft Windows App 或其他支援 RDP 的用戶端，連線到 Linux RDP Server。

但要區分：

- macOS 作為 RDP Client：可以。
    
- macOS 作為原生 RDP Server：系統沒有內建 Microsoft RDP Server。
    

macOS 原生螢幕共享主要使用 VNC / Apple Remote Desktop 協定。

---

# Part 5：常見錯誤與 Troubleshooting

## 13. Windows 顯示驗證錯誤

Windows 可能出現：

```
發生驗證錯誤。
有更多資訊可供使用。
```

GNOME Remote Desktop 日誌可能顯示：

```
[transport_accept_nla]: client authentication failure
```

```
[rdp_server_accept_nego]:
server supports only NLA Security
```

```
Protocol security negotiation failure
```

```
[freerdp_tls_handshake]:
BIO_do_handshake failed
```

### 13.1 錯誤原因

可能原因：

1. RDP 第一階段帳號密碼錯誤。
    
2. Windows 使用了舊的快取憑證。
    
3. GNOME Remote Desktop 與 Windows NLA / CredSSP 存在相容性問題。
    
4. TLS 憑證或握手失敗。
    
5. RDP 用戶端嘗試了伺服器不支援的安全模式。
    

這些日誌可能是多次協商嘗試的結果，不一定代表每一行都是獨立故障。

### 13.2 清除 Windows RDP 憑證

Windows CMD：

```
cmdkey /delete:TERMSRV/192.168.8.45
```

重新開啟：

```
mstsc
```

再次輸入 GNOME Remote Login 的帳號密碼。

### 13.3 查看 GNOME RDP 日誌

```
sudo journalctl \
  -u gnome-remote-desktop.service \
  -f
```

重新連線並觀察錯誤。

### 13.4 檢查版本

```
gnome-shell --version
```

```
apt policy gnome-remote-desktop
```

Rocky Linux：

```
rpm -q gnome-remote-desktop
```

部分 GNOME Remote Desktop 版本可能存在用戶端相容性問題，應優先確認更新及已知問題。

不建議為了排除問題，直接停用 NLA 或降低 TLS 安全性。

## 14. RDP 登入成功，但畫面全黑

這是 GNOME Remote Login 另一類常見問題。

與前面的 NLA 驗證錯誤不同，黑畫面代表連線可能已經進入工作階段建立或圖形顯示階段。

可能原因：

- GDM 無法正常建立遠端工作階段。
    
- GNOME Shell 啟動失敗。
    
- Wayland / Mutter 問題。
    
- 虛擬 GPU 或渲染相容性問題。
    
- 已存在的登入工作階段造成衝突。
    
- GNOME Remote Desktop 特定版本的 Bug。
    

### 14.1 檢查登入工作階段

```
loginctl list-sessions
```

查看 GNOME 相關程序：

```
ps aux | grep -E \
  'gnome-shell|gnome-session|gdm'
```

### 14.2 查看 GDM 日誌

Ubuntu：

```
sudo journalctl -u gdm3 \
  -b -n 100 --no-pager
```

Rocky Linux：

```
sudo journalctl -u gdm \
  -b -n 100 --no-pager
```

### 14.3 查看 RDP 日誌

```
sudo journalctl \
  -u gnome-remote-desktop.service \
  -b -n 100 --no-pager
```

### 14.4 重新連線測試

如果登入後黑畫面，可以先：

1. 關閉 RDP 視窗。
    
2. 等待數秒。
    
3. 重新建立 RDP 連線。
    
4. 觀察是否能正常顯示桌面。
    

如果重新連線後恢復，應進一步檢查 GNOME 工作階段建立與交接問題。

## 15. RDP Port 無法連線

Linux 檢查：

```
sudo ss -lntp | grep -E '3389|3390'
```

Windows PowerShell：

```
Test-NetConnection 192.168.8.45 -Port 3389
```

如果 `TcpTestSucceeded` 為 `False`，檢查：

- RDP Server 是否啟動。
    
- 是否監聽正確 IP / Port。
    
- Linux Firewall。
    
- Proxmox Firewall。
    
- VMware 虛擬網路設定。
    
- 上游網路 ACL。
    

如果 TCP 已連通但驗證失敗，應轉往 NLA / TLS / 帳密方向調查。

## 16. xrdp 登入黑畫面

先檢查：

```
sudo journalctl -u xrdp \
  -b -n 100 --no-pager
```

```
sudo journalctl -u xrdp-sesman \
  -b -n 100 --no-pager
```

確認使用者的桌面工作階段設定：

```
cat ~/.xsession
```

如果使用 XFCE，應確認：

```
exec startxfce4
```

另外，避免同一個 Linux 使用者同時在本機及 xrdp 建立互相衝突的桌面工作階段。

---

# Part 6：Proxmox VE / ESXi 虛擬機注意事項

## 17. Linux RDP 與 Hypervisor 效能

GNOME Remote Desktop 的效能不只取決於網路頻寬，也與以下因素有關：

- CPU 虛擬化設定。
    
- 虛擬 GPU 與顯示驅動。
    
- GNOME Shell / Mutter。
    
- Wayland 工作階段。
    
- Guest 記憶體。
    
- 磁碟 I/O 延遲。
    
- Hypervisor CPU 排程。
    

### 17.1 Proxmox CPU Type

Proxmox 常見 CPU Type：

```
host
x86-64-v2-AES
x86-64-v3
```

`host` 通常能暴露較完整的實體 CPU 功能，但不保證所有 Guest 工作負載都具有最佳延遲表現。

如果變更 CPU Type 後發現明顯差異，應在相同 VM、相同負載下進行 A/B 測試。

修改 CPU Type 後應完整關機，再重新啟動 VM。

### 17.2 檢查虛擬 GPU

在 Linux VM：

```
lspci -nnk | grep -A 4 -Ei \
  'VGA|Display|3D'
```

安裝 Mesa 工具：

```
sudo apt install -y mesa-utils
```

查看渲染器：

```
glxinfo -B
```

如果顯示：

```
llvmpipe
```

代表該 OpenGL 測試目前使用 CPU 軟體渲染。

但必須注意：`glxinfo` 只能反映執行該命令的圖形環境，不能單獨證明 GNOME RDP 遠端工作階段的實際渲染路徑。

### 17.3 檢查磁碟等待

```
sudo apt install -y sysstat
```

```
iostat -xz 1
```

重點觀察：

```
r_await
w_await
aqu-sz
```

### 17.4 檢查 CPU 等待

```
vmstat 1
```

重點觀察：

- `wa`：I/O Wait。
    
- `st`：CPU Steal Time。
    
- `r`：等待 CPU 執行的工作數量。
    

不要在尚未確認瓶頸前，直接認定 LVM-Thin、Cache 或 GPU 是卡頓主因。

---

# Part 7：常用指令速查表

## 18. GNOME Remote Desktop

|用途|指令|
|---|---|
|查看 Remote Login|`sudo grdctl --system status`|
|查看 Desktop Sharing|`grdctl status`|
|啟用 Remote Login RDP|`sudo grdctl --system rdp enable`|
|停用 Remote Login RDP|`sudo grdctl --system rdp disable`|
|查看 System Service|`sudo systemctl status gnome-remote-desktop.service`|
|查看 User Service|`systemctl --user status gnome-remote-desktop.service`|
|即時查看 System 日誌|`sudo journalctl -u gnome-remote-desktop.service -f`|
|查看 RDP Port|`sudo ss -lntp \| grep 3389`|

## 19. xrdp

|用途|指令|
|---|---|
|啟動 xrdp|`sudo systemctl enable --now xrdp`|
|查看狀態|`sudo systemctl status xrdp`|
|查看日誌|`sudo journalctl -u xrdp -f`|
|查看 Sesman 日誌|`sudo journalctl -u xrdp-sesman -f`|
|重新啟動|`sudo systemctl restart xrdp`|

## 20. Rocky Linux Firewall

```
sudo firewall-cmd --get-active-zones
```

```
sudo firewall-cmd --permanent --add-service=rdp
```

```
sudo firewall-cmd --reload
```

```
sudo firewall-cmd --list-all
```

---

# Part 8：安全性建議

RDP 屬於遠端管理服務，應避免直接暴露在公網。

建議：

1. 優先透過 VPN、Tailscale 或其他安全存取通道連線。
    
2. 使用強密碼，避免共用管理員帳號。
    
3. 只允許必要來源網段存取 TCP 3389。
    
4. 定期更新 GNOME Remote Desktop、FreeRDP、xrdp。
    
5. 使用可信任的 TLS 憑證，或確認伺服器憑證指紋。
    
6. 保留系統日誌以利問題追蹤。
    
7. 不要為了排錯直接停用 SELinux 或整個防火牆。
    

# 21. 結論

Linux RDP 已經不再只有傳統的 xrdp。

GNOME 46 之後，GNOME Remote Desktop 已能整合 GDM、Wayland 與 RDP，提供更接近 Windows Remote Desktop 的登入體驗。

對於不同 Linux 發行版，可以採取以下方向：

- **Ubuntu 24.04+**：優先使用 GNOME Remote Login。
    
- **Rocky Linux 10**：優先使用 GNOME Remote Desktop。
    
- **Rocky Linux 9**：可使用 xrdp + Xorg。
    
- **舊版 Linux 或 XFCE 環境**：xrdp 仍是實用方案。
    

部署時應先確認 RDP 模式、服務狀態、監聽 Port 與防火牆，再處理 NLA 驗證及圖形工作階段問題。

尤其要區分：

**NLA 驗證失敗、登入後黑畫面，以及操作延遲，是三種不同階段的問題。**

只要依照網路連通性、RDP 驗證、GDM 工作階段、圖形渲染的順序排查，就能有效縮小問題範圍。

---

## 參考資料

1. GNOME 官方 Remote Login 文件  
    [https://help.gnome.org/gnome-help/remote-login.html](https://help.gnome.org/gnome-help/remote-login.html)
    
2. GNOME Remote Desktop 官方專案  
    [https://github.com/GNOME/gnome-remote-desktop](https://github.com/GNOME/gnome-remote-desktop)
    
3. GNOME Remote Desktop Configuration  
    [https://github.com/GNOME/gnome-remote-desktop/blob/main/docs/configuration.md](https://github.com/GNOME/gnome-remote-desktop/blob/main/docs/configuration.md)
    
4. Rocky Linux 官方 RDP 教學  
    [https://docs.rockylinux.org/desktop/gnome/rdp-server/](https://docs.rockylinux.org/desktop/gnome/rdp-server/)
    
5. Rocky Linux 10 Release Notes  
    [https://docs.rockylinux.org/latest/releases/release_notes/10_0/](https://docs.rockylinux.org/latest/releases/release_notes/10_0/)
    
6. xrdp 官方 GitHub  
    [https://github.com/neutrinolabs/xrdp](https://github.com/neutrinolabs/xrdp)
    
7. Ubuntu xrdp Community Documentation  
    [https://help.ubuntu.com/community/xrdp](https://help.ubuntu.com/community/xrdp)