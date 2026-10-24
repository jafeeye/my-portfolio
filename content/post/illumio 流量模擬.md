---
title: illumio LXC ncat
date: 2026-06-16
toc: true
---
```toc
```

### 一、測試前置步驟
1. 使用Debian 13 LXC 安裝，腳本安裝前先裝以下套件
```
# 1.Debian LXC 安裝套件
apt update && apt install -y uuid-runtime iproute2 iptables ipset ca-certificates curl diffutils dnsutils libnfnetlink0 libcap2 libgmp10 mawk

# Ubuntu LXC 安裝套件
apt install curl

# 2.systemd-resolved 讓容器可以讀取PVE DNS欄位
apt update && apt install systemd-resolved -y
```

或者是避免hosts被覆蓋
```
touch /etc/.pve-ignore.hosts
echo "192.168.8.8 illumio-kevin.dev" >> /etc/hosts
```

2. 找一台設定好LXC，把Script 設定好執行
```
(
set -euo pipefail

# 來源 LXC 範本 ID
TEMPLATE_ID=900

# 新 LXC 從哪個 CT ID 開始
START_ID=201

# 目標儲存
STORAGE="local-lvm"

# 按照你想要的順序填入 hostname
HOSTS=(
  sandra-core0
  sandra-core1
  sandra-data0
  sandra-data1
)

# 先確認所有目標 ID 都沒有被 VM 或 LXC 使用
for index in "${!HOSTS[@]}"; do
  id=$((START_ID + index))

  if [[ -e "/etc/pve/lxc/$id.conf" ||
        -e "/etc/pve/qemu-server/$id.conf" ]]; then
    echo "錯誤：ID $id 已被使用，停止執行。"
    exit 1
  fi
done

# 按清單順序，逐台複製
for index in "${!HOSTS[@]}"; do
  id=$((START_ID + index))
  hostname="${HOSTS[$index]}"

  echo "正在建立：CT $id → $hostname"

  pct clone "$TEMPLATE_ID" "$id" \
    --hostname "$hostname" \
    --full 1 \
    --storage "$STORAGE"
done

echo "全部複製完成。"
)
```

3. 製作`/root/root-ca.crt` 、`/root/pair.sh`，直接用pct容器直接大量配對
```
(
set -euo pipefail

CTS=(300 301 302 303)
CA="/root/root-ca.crt"
PAIR="/root/pair.sh"

[[ -f "$CA" && -f "$PAIR" ]] || {
  echo "找不到憑證或配對腳本，請確認路徑。"
  exit 1
}

for id in "${CTS[@]}"; do
  echo "========== 處理 CT $id =========="

  if [[ $(pct status "$id") != "status: running" ]]; then
    echo "CT $id 尚未啟動，請先啟動後重試。"
    exit 1
  fi

  # 建立 CA 憑證目錄
  pct exec "$id" -- mkdir -p /usr/local/share/ca-certificates

  # 複製並信任 CA 憑證
  pct push "$id" "$CA" \
    /usr/local/share/ca-certificates/lab-root-ca.crt \
    --perms 0644

  pct exec "$id" -- update-ca-certificates

  # 複製配對腳本，限制只有 root 可讀取與執行
  pct push "$id" "$PAIR" /root/pair.sh --perms 0700

  # 執行腳本
  pct exec "$id" -- bash /root/pair.sh

  # 成功後移除容器內的配對腳本
  pct exec "$id" -- rm -f /root/pair.sh

  echo "CT $id 完成"
done
)
```

### 二、加入Windows AD
```
apt update
apt install -y sssd-ad sssd-tools realmd adcli libnss-sss libpam-sss samba-common-bin krb5-user
```

```
dig @192.168.8.131 ad.test
dig @192.168.8.131 _ldap._tcp.ad.test SRV
dig @192.168.8.131 _kerberos._tcp.ad.test SRV
dig @192.168.8.131 _ldap._tcp.dc._msdcs.ad.test 

##
realm join -v ad.test -U Administrator
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

看安裝錯誤訊息
/var/log/illumio_install.log
hostname做restart 就會同步過去

### Rocky Linux
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

### 查看nft
```
# 看有多少個清單
nft list tables
# 顯示防火牆規則
nft list ruleset
# 刪除清單
nft delete table inet ILO-FILTER-X

```







### nc 模擬流量
```
dnf install -y nmap-ncat
apt update && apt install ncat -y
# -l: 進入監聽模式 (Listen) 
# -p: 指定連接埠號碼 (Port) 
# -v: 顯示詳細日誌 (Verbose) 
nc -lvp 8444
# 另一台電腦
nc -v 192.168.8.8 8444
```

發起多個Port
```
## 接收
for port in 20 21 53 3389; do while true; do nc -l -k -p $port > /dev/null 2>&1; sleep 1; done & done

## 發起
for port in 20 21 53 3389; do while true; do nc 172.16.7.107 $port < /dev/null; sleep 1; done & done

```

改良後腳本
```
#!/bin/bash

# 所有測試主機 IP
IPS=(
    172.16.7.107
    172.16.7.108
    172.16.7.109
)

# 測試 Port
PORTS=(
    20
    21
    53
    3389
)

# 取得本機主要 IPv4
MY_IP=$(hostname -I | awk '{print $1}')

echo "Local IP: $MY_IP"
echo "Starting listeners..."

# =========================
# 接收端
# =========================
for port in "${PORTS[@]}"; do
    while true; do
        nc -l -k -p "$port" > /dev/null 2>&1
        sleep 1
    done &
done

# =========================
# 發送端
# =========================
echo "Starting connections..."

for ip in "${IPS[@]}"; do

    # 跳過自己的 IP
    if [[ "$ip" == "$MY_IP" ]]; then
        echo "Skip local IP: $ip"
        continue
    fi

    for port in "${PORTS[@]}"; do
        while true; do
            nc -w 1 "$ip" "$port" < /dev/null
            sleep 1
        done &
    done

done

# 等待所有背景程序
wait
```


驗證是否在背景 `jobs`
查詢執行程式 ps aux | grep nc
結束程式 `kill -9 $(jobs -p)`
![](Pasted%20image%2020260616150724.png)

ncat 如果出現Connection refused 代表port可能被ncat 以外佔用,timeout 確定雙方無法連線