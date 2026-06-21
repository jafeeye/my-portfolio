---
title: DualBoot 多重開機
toc: true
date: 2026-06-21
---
## Macbook 安裝 Fedora 跟 MacOS共存
1. 按下電源鍵後馬上按下 `Cmd+R` 不放 , 停在蘋果logo好幾秒，等到進度條出現就可以放開
2. 進入到復原模式，在終端機輸入 `csrutil disable` 關閉SIP
3. 重開機後按住 Option 不放，畫面一樣停在蘋果logo好幾秒，後面就會出現選擇開機磁碟，選擇用做好的Ventoy隨身碟開機
4. 選擇Fedora安裝映像檔，在grub模式啟動
5. 進入桌面Live CD 環境，先安裝GParted分出三塊，分別把安裝要對應的根目錄 `/` `/boot` `/boot/efi` 安裝到對應磁區就可，最後再按套用掛載點並安裝
6. 重開機進入Fedora完成安裝，開機按下Option即可選擇MacOS系統

| 分割區       | 磁區名稱 | 掛載點       | 格式    | flag     | 說明            |
| --------- | ---- | --------- | ----- | -------- | ------------- |
| /dev/sda1 | EFI  |           | fat32 | boot,esp | MacOS開機EFI磁區  |
| /dev/sda2 |      |           | Apfs  |          | MacOS系統資料存放區  |
| /dev/sda3 | EFI  | /boot/efi | fat32 | boot,esp | Fedora開機EFI磁區 |
| /dev/sda4 |      | /boot     | Ext4  |          | Fedora boot   |
| /dev/sda5 |      | /         | Ext4  |          | Fedora根目錄     |

![](Pasted%20image%2020260621104023.png)