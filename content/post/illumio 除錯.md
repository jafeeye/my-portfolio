
使用Debian 13 LXC 安裝
```
apt install -y uuid-runtime iproute2 iptables ipset ca-certificates curl diffutils dnsutils libnfnetlink0 libcap2 libgmp10 mawk
```

看安裝錯誤訊息
/var/log/illumio_install.log


避免hosts被覆蓋
```
touch /etc/.pve-ignore.hosts
echo "192.168.8.8 illumio-kevin.dev" >> /etc/hosts
```

hostname做restart 就會同步過去



## Rocky Linux
使用Rocky Linux 9 LXC 安裝
```
dnf install -y dmidecode ipset
```
遇到openssl 3.0錯誤
```
# 1. 既然 /proc/sys 不給改，我們直接用 tmpfs 把整個 /proc/sys 蓋過去！
# （放心，這只會影響容器內的這一層虛擬路徑，絕對不會弄壞宿主機）
mount -t tmpfs tmpfs /proc/sys

# 2. 蓋過去之後，現在 /proc/sys 變成一個乾淨且完全可寫的記憶體空間了！
# 我們趕緊把一整路需要的資料夾通通蓋出來：
mkdir -p /proc/sys/crypto

# 3. 順利建立檔案，並塞入 OpenSSL 死活都要看的 0
echo "0" > /proc/sys/crypto/fips_enabled

# 4. 給予所有人讀取權限
chmod 444 /proc/sys/crypto/fips_enabled

# 5.驗證是否為0
cat /proc/sys/crypto/fips_enabled
```
寫進rc.local，讓他重開機可以重新執行
```
# 用 cat 直接將指令覆蓋寫入 /etc/rc.d/rc.local

cat << 'EOF' > /etc/rc.d/rc.local
#!/bin/bash
# 修正 Rocky Linux 9 容器內 OpenSSL 讀不到 FIPS 的靈異現象
# 用 tmpfs 把整個 /proc/sys 蓋過去
mount -t tmpfs tmpfs /proc/sys
# 建立資料夾
mkdir -p /proc/sys/crypto
# 塞入 OpenSSL 必看的 0
echo "0" > /proc/sys/crypto/fips_enabled
# 給予讀取權限
chmod 444 /proc/sys/crypto/fips_enabled
# （選用）寫入一條系統 Log 方便未來排障
echo "[$(date)] OpenSSL FIPS tmpfs fix applied successfully." >> /var/log/fips_fix.log
EOF

```
賦予權限並開機執行
```
chmod +x /etc/rc.d/rc.local
# 強行讓rocky linux 9 能用 rc.local服務
printf "\n[Install]\nWantedBy=multi-user.target\n" >> /usr/lib/systemd/system/rc-local.service

# 讓 systemd 重新載入設定檔 
systemctl daemon-reload 

# 設定 rc-local 服務開機自動執行 
systemctl enable rc-local.service 

# 立刻在背景試跑一次看看 
systemctl start rc-local.service
```

## 查看nft
```
# 看有多少個清單
nft list table
# 顯示防火牆規則
nft list ruleset
# 刪除清單
nft delete table inet ILO-FILTER-X

```
 

## nc 模擬流量
```
dnf install -y nmap-ncat
# -l: 進入監聽模式 (Listen) 
# -p: 指定連接埠號碼 (Port) 
# -v: 顯示詳細日誌 (Verbose) 
nc -lvp 8444
# 另一台電腦
nc -v 192.168.8.8 8444
```

安裝 openssh server
```
# 如果沒反應，代表沒裝或沒開，直接物理安裝： 
dnf install -y openssh-server 
# 啟動並設定開機自動執行 
systemctl enable --now sshd
vi /etc/ssh/sshd_config
PermitRootLogin yes
systemctl restart sshd
apt update && apt install openssh-server
systemctl enable --now ssh
```
