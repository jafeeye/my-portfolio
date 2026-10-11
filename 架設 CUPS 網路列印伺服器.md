---
title: Proxmox LXC 架設 CUPS 網路列印伺服器：HP LaserJet P1005 實作教學
toc: true
date: 2026-10-11
---
## 一、實作環境

本次使用 Proxmox VE 建立 Debian 13 LXC Container，安裝 CUPS 列印服務，並將 HP LaserJet P1005 透過 USB Passthrough 提供給容器使用。
由於 HP LaserJet P1005 屬於需要由主機載入 Firmware 的印表機，因此每次印表機重新通電後，都需要重新傳送 Firmware，才能正常列印。
![](static/Pasted%20image%2020261011205129.png)
### 環境資訊

|項目|配置|
|---|---|
|虛擬化平台|Proxmox VE|
|Container ID|193|
|作業系統|Debian 13|
|CPU|1 Core|
|RAM|512 MB|
|磁碟|2 GB|
|列印服務|CUPS 2.4.x|
|印表機|HP LaserJet P1005|
|USB Vendor/Product ID|`03f0:3d17`|
|驅動|Foomatic/foo2xqx|
|USB 裝置|`/dev/usb/lp0`|
|CUPS Device URI|`parallel:/dev/usb/lp0`|
|CUPS IP|`192.168.8.86`|
|網路列印|IPP / AirPrint|



### 最終架構

```
Windows / macOS / iPhone / iPad
             |
          LAN / IPP
             |
       Proxmox VE
             |
       LXC CT 193
       Debian 13
             |
       CUPS + Avahi
       foo2xqx Driver
             |
     /dev/usb/lp0
             |
    HP LaserJet P1005
```

---

## 二、建立 Debian LXC

在 Proxmox 建立 Debian 13 Container。

建議配置：

- CPU：1 Core
    
- RAM：512 MB
    
- Disk：2～4 GB
    
- Network：vmbr0
    
- IP：DHCP 或固定 IP
    

本次使用 CT ID `193`。

建立完成後，先將 HP LaserJet P1005 的 USB 直接連接至 Proxmox Host。

## 三、確認 Proxmox Host 辨識印表機

以下指令均在 Proxmox Host 執行。

### 1. 檢查 USB 裝置

```
lsusb
```

預期顯示：

```
Bus 001 Device 004: ID 03f0:3d17 HP, Inc LaserJet P1005
```

### 2. 確認 usblp 驅動

```
modprobe usblp
lsusb -t
```

預期可看到：

```
Class=Printer, Driver=usblp
```

### 3. 確認 USB Printer Device

```
ls -l /dev/usb/lp0
```

預期顯示：

```
crw-rw---- 1 root lp 180, 0 /dev/usb/lp0
```

也可以透過以下指令確認裝置對應的印表機：

```
udevadm info -a -n /dev/usb/lp0 | grep -E 'idVendor|idProduct|product'
```

確認 Vendor ID 為 `03f0`、Product ID 為 `3d17`。

## 四、將 USB 裝置映射到 LXC

在 Proxmox Web UI 操作：

**CT 193 → Resources → Add → Device**

設定如下：

|項目|設定|
|---|---|
|Device Path|`/dev/usb/lp0`|
|UID in CT|`0`|
|GID in CT|`7`|
|Access Mode in CT|`0660`|
|Read only|不勾選|

或者直接透過 Proxmox Host CLI：

```
pct stop 193

pct set 193 --dev0 path=/dev/usb/lp0,uid=0,gid=7,mode=0660

pct start 193
```

完成後，容器設定檔應包含：

```
dev0: /dev/usb/lp0,uid=0,gid=7,mode=0660
```

這個方式不需要另外映射 `/dev/bus/usb/001`，因為本次實作採用 Linux `usblp` 裝置介面。

### 確認容器內裝置

進入 LXC：

```
pct enter 193
```

執行：

```
ls -l /dev/usb/lp0
```

預期顯示：

```
crw-rw---- 1 root lp 180, 0 /dev/usb/lp0
```

其中 GID `7` 是 Debian 的 `lp` 群組，提供 CUPS 列印服務存取裝置的權限。

---

## 五、安裝 CUPS 與印表機驅動

在 Debian LXC 執行：

```
apt update
apt install -y cups cups-client \
  printer-driver-foo2zjs \
  wget usbutils
```

啟用 CUPS：

```
systemctl enable --now cups
```

確認：

```
systemctl status cups
```

### 確認 P1005 驅動

```
lpinfo -m | grep -i P1005
```

選擇：

```
HP LaserJet P1005 Foomatic/foo2xqx
```

注意，P1005 不建議使用 Generic PCL 或 PostScript 驅動。

## 六、下載 HP LaserJet P1005 Firmware

這是本次實作最重要的部分。

HP LaserJet P1005 的 Firmware 需要由主機載入。當印表機重新通電後，可能無法直接列印，必須重新傳送 Firmware。

### 1. 確認 Firmware 是否存在

```
ls -lh /lib/firmware/hp/sihpP1005.dl
```

若已存在非空檔案，可跳過下載程序。

### 2. 使用 Debian 內建 getweb

```
cd /tmp
getweb P1005
```

本次實作發現 Debian 13 的 `getweb` 下載來源可能無法連線：

```
https://www.quirinux.org/printers/sihpP1005.tar.gz
```

錯誤：

```
Connection timed out
```

因此本次改採第三方備份來源下載 P1005 Firmware 映像檔。第三方檔案應先確認來源可信、檔案完整性及授權條件。

```
cd /tmp

curl -fL \
  -o sihpP1005.img \
  https://raw.githubusercontent.com/faradayfury/printer-all/main/foo2zjs/sihpP1005.img
```

再透過 `arm2hpdl` 轉換：

```
mkdir -p /lib/firmware/hp

arm2hpdl /tmp/sihpP1005.img \
  > /lib/firmware/hp/sihpP1005.dl
```

確認：

```
ls -lh /lib/firmware/hp/sihpP1005.dl
```

本次產生的檔案約 218 KB。檔案大小僅供參考，不代表已完成完整性驗證。

---

## 七、將 Firmware 載入印表機

**這是本次成功列印的關鍵步驟。**

先確認印表機已開機，且目前沒有進行中的列印工作。

在 Debian LXC 執行：

```
cat /lib/firmware/hp/sihpP1005.dl > /dev/usb/lp0
```

此指令會將 Firmware 資料直接傳送到 USB 印表機。

成功傳送後，觀察印表機是否有反應，再進行列印測試。

### 重要注意事項

本次測試發現：

- 印表機重新通電後，手動傳送 Firmware 可以正常運作。
    
- 如果印表機已經載入 Firmware，重複執行上傳指令可能造成 USB 寫入卡住。
    
- 單純重新啟動 LXC，不代表印表機需要再次載入 Firmware。
    
- 不建議將上述 `cat` 指令無條件綁定在每次 CUPS 或 LXC 啟動流程。
    

因此，較合理的管理方式是：印表機重新通電並需要 Firmware 時，再執行載入程序。

---

## 八、設定 CUPS 印表機

使用瀏覽器進入：

```
http://192.168.8.86:631
```

前往：

Administration → Add Printer

選擇 HP LaserJet P1005，並使用：

```
HP LaserJet P1005 Foomatic/foo2xqx
```

本次實測發現，使用標準 CUPS `usb://` Backend 時，雖然能偵測裝置，但無法正常列印。

因此最後使用：

```
parallel:/dev/usb/lp0
```

此方式雖然 URI 名稱為 `parallel`，但實際連接仍然是 USB，透過 Linux Kernel 的 `usblp` 介面存取印表機。

設定指令：

```
lpadmin -p P1005 -v parallel:/dev/usb/lp0

cupsenable P1005
cupsaccept P1005
```

確認：

```
lpstat -v P1005
```

預期：

```
device for P1005: parallel:/dev/usb/lp0
```

### 列印測試

```
lp -d P1005 /etc/hostname
```

也可以透過 CUPS 管理介面：

Maintenance → Print Test Page

本次在正確載入 Firmware 並修正 USB 裝置權限後，已成功列印。

---

## 九、設定 AirPrint 網路列印

為了讓 iPhone、iPad、macOS 裝置透過網路找到印表機，可以使用 CUPS + Avahi。

### 1. 安裝 Avahi

```
apt install -y avahi-daemon avahi-utils dbus
```

啟用：

```
systemctl enable --now avahi-daemon
```

### 2. 開啟 CUPS 共享

```
cupsctl --share-printers

lpadmin -p P1005 -o printer-is-shared=true
```

重新啟動：

```
systemctl restart cups avahi-daemon
```

### 3. 檢查 IPP 廣播

```
avahi-browse -rt _ipp._tcp
```

確認區網中可以探索到共享的 P1005。

iPhone AirPrint 還需要適當的 DNS-SD 能力資訊及相容的文件格式；若能探索但不能列印，應進一步檢查 AirPrint TXT 紀錄及 IPP 格式支援。

### 4. iPhone 測試

iPhone 連接相同區網後：

1. 開啟照片、Safari 或 PDF。
    
2. 點選分享 → 列印。
    
3. 選擇 HP LaserJet P1005。
    
4. 送出測試列印。
    

若 Proxmox 防火牆有啟用，需確認內網允許：

|通訊|Port|
|---|---|
|IPP|TCP 631|
|mDNS / Bonjour|UDP 5353|

不要直接將 CUPS 的 631 Port 公開到 Internet。

---

## 十、常見問題與排除方式

|問題|原因或排查方式|
|---|---|
|CUPS 顯示 Completed，但沒印出來|確認 Firmware 是否載入|
|`/dev/usb/lp0` 不存在|確認 Host `usblp` 驅動及 Device Passthrough|
|`Permission denied`|確認裝置 GID 與 CUPS 存取權限|
|`Device or resource busy`|檢查是否有其他列印或 Firmware 載入程序|
|Firmware `cat` 卡住|可能重複上傳、USB 裝置未就緒或 USB I/O 異常|
|`usb://` 偵測正常卻無法列印|可檢查 libusb 權限及 Host 核心驅動；本次改用 `/dev/usb/lp0`|
|LXC 重啟後列印異常|檢查裝置映射及印表機 Firmware 狀態|
|AirPrint 找不到印表機|檢查 Avahi、IPP 共享、mDNS Multicast 與防火牆|

### 實用檢查指令

Proxmox Host：

```
lsusb
lsusb -t
ls -l /dev/usb/lp0
pct config 193
```

Debian LXC：

```
ls -l /dev/usb/lp0
lpstat -t
lpstat -v P1005
systemctl status cups
tail -n 50 /var/log/cups/error_log
```

---

## 十一、實作結論

本次成功將 HP LaserJet P1005 整合至 Proxmox Debian 13 LXC，透過 CUPS 提供網路列印服務，並搭配 Avahi 提供 AirPrint 裝置探索與列印功能。

最後成功的核心設定為：

**1. Proxmox LXC USB Passthrough**

```
dev0: /dev/usb/lp0,uid=0,gid=7,mode=0660
```

**2. CUPS Device URI**

```
parallel:/dev/usb/lp0
```

**3. 印表機 Firmware 載入**

```
cat /lib/firmware/hp/sihpP1005.dl > /dev/usb/lp0
```

**4. AirPrint**

透過 CUPS IPP Sharing + Avahi Bonjour/mDNS 提供區網列印。

本次最大的心得是：**HP LaserJet P1005 並非單純安裝 CUPS 驅動後就能正常列印，還需要正確載入 Firmware。**

而且 Firmware 的載入時機很重要。對本次環境而言，應避免在每次 LXC 啟動時無條件重新傳送 Firmware，以免造成印表機 USB I/O 卡住。

只要完成 Firmware 載入、正確 USB 裝置映射及 CUPS 驅動設定，即可讓這台舊款印表機繼續透過現代 Linux 列印伺服器提供網路列印服務。


