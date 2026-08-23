---
title: illumio Debug
toc: true
date: 2026-08-22
---
## 假設環境
基本上遇到10.100.100.x，就要確認4台機器是不是都在vlan 100 上，並可以互相連線
```
                    Core / Distribution
                           │
              ┌────────────┴────────────┐
              │                         │
         Firewall / NSX            L3 Switch ACL
              │                         │
     ┌────────┼────────┐
     │        │        │
 VLAN 100  VLAN 25  VLAN 130
 Server    Illumio    Management
10.100.100 10.100.25 10.100.130
```
切出來的Vlan
```
10.100.101.0/24  VMware
10.100.102.0/24  Hyper-V
10.100.103.0/24  Nutanix
10.100.104.0/24  Illumio / Security
10.100.110.0/24  Windows Servers
10.100.120.0/24  Management
```
檢查網路指令
```
ip route get 10.100.104.216
ip neigh show 10.100.104.216

```






叢集檢查指令
```
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-env check
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl cluster-status
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl cluster-members
## 叢集停止
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl cluster-stop

```



Log 所有檔案
```
ls -lah /var/log/illumio-pce/

```
憑證問題
自簽2層在snc0或2x2都可以順利安裝
```
illumio-pce-env setup --test 5 --list
```
![](static/Pasted%20image%2020260822170931.png)
修掉下面錯誤
![](static/Pasted%20image%2020260822170003.png)
```
#改擁有者
chown ilo-pce:ilo-pce /var/lib/illumio-pce/cert/server.key
#改執行權限
chmod 400 /var/lib/illumio-pce/cert/server.key
#改runtime.yml 權限
chmod 640 /etc/illumio-pce/runtime_env.yml
```
![](static/Pasted%20image%2020260822170723.png)
```
沒有三層憑證的意思，指令自簽不用理他，只要下面pass一樣可以啟動
```

換憑證
```
rm -rf /etc/pki/ca-trust/source/anchors/server.crt
rm -rf /var/lib/illumio-pce/cert/server.key
rm -rf /var/lib/illumio-pce/cert/server.crt

```



```
                   core0 PARTIAL
                         │
              cluster-members alive?
                    /          \
                  YES           NO
                   │             │
            查 core0 service    查網路/Consul
                   │
          哪個 required service 缺？
                   │
          ┌────────┼────────┐
        port      bind IP    config
       衝突       /NIC       /殘留資料

```


連線測試
dig、nslookup 本身不能查hosts裡面檔案,ping會去讀hosts 
```
# 先確認 OS 現在解析正確
hostname -f
getent hosts sandra-data1
getent hosts sandra-data1.dpdns.org

# 再確認四台名稱
getent hosts sandra-core0.dpdns.org
getent hosts sandra-core1.dpdns.org
getent hosts sandra-data0.dpdns.org
getent hosts sandra-data1.dpdns.org
```





調整特殊閥值
```
illumio-pce-env metrics -h
```

## 調整
換IP ：不能直接改yml然後runlevel1到runlevel5，因為consul.json會殘留紀錄
```
## 1.stop
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl stop
## 2.reset (全部重置包括db)
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl reset
## 3.env check
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-env check
## 4.cert check
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-env setup --test 5 --list
## 5.start runlvel 1
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl start --runlevel 1
## 6. 確認跑到running
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl cluster-status -w


## ------------只有第一台要貼完，分隔線上面貼另外三台
## 7. 重建db
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-db-management setup
## 8. 跑到runlvel 5
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl start --runlevel 5
## 9. 設帳號
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-db-management create-domain --user-name admin@bd1.dev --full-name 'admin' --org-name 'Office.'

```



```
1.4台執行 sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl stop
2.改完yml的ip執行確認env sudo -u ilo-pce /opt/illumio-pce/illumio-pce-env check
3.確認憑證無問題 illumio-pce-env setup --test 5 --list
4.在隨便其中一台執行 sudo -u ilo-pce illumio-pce-ctl cluster-join <IP>，然後那台被加入IP那台啟動sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl start --runlevel 1，並依序加入多台
5.確認/var/lib/illumio-pce/runtime/config/consul/consul.json 的IP是否更新
6.使用sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl cluster-members 確認各台狀況



*如果單純改yml切去runlevel1是會出錯的，因為/var/lib/illumio-pce/runtime/config/consul/consul.json 殘留舊叢集IP
```

快速重置
```
## 1.stop
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl stop
## 2.reset (全部重置包括db)
sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl reset
```
快速重置db

更換憑證



解除安裝
```
## 1.移除
rpm -e illumio-pce
rpm -e illumio-pce-ui
## 2.刪除目錄
rm -rf /var/lib/illumio-pce
rm -rf /var/log/illumio-pce
rm -rf /etc/illumio-pce
```


一開始部屬
```
記得一開始裝英文版rockylinux
```


## 資料倒回



## 負載平衡
DNS Load Balancing (DNS round-robin)
```
pce_fqdn: xxx.dpdns.org
service_discovery_fqdn: xxx.dpdns.org
cluster_public_ips:
  cluster_fqdn:
  - 192.168.8.25
  - 192.168.8.26
```


HAProxy

```
                    DNS
                     │
		        illumio.bd1.dev
                     │
                     ▼
              HAProxy VIP
            192.168.8.20
                     │
             ┌───────┴───────┐
             │               │
          core0             core1
      192.168.8.25      192.168.8.26
          :8443             :8443

        data0             data1
    192.168.8.27      192.168.8.28
        不進 LB            不進 LB
```

```
ilo.pdn.dpdns.org.   A   192.168.8.20
```
## 反向代理+負載平衡






## 防火牆阻擋測試

![](static/Pasted%20image%2020260822185657.png)

pve的放火牆無法立即阻斷，要等原本連線斷掉才生效
測試一定要兩台雙方測試 因為可以只擋一邊
## 安裝Agent 測試
```
8443這邊代替443 port功能
ipconfig /flushdns
Test-NetConnection test.dpdns.org -Port 8443
curl.exe -vk https://test.dpdns.org:8443
Resolve-DnsName test.dpdns.org



resolvectl flush-caches
ip -br addr
```



```
nc -lvp 8300  nc <ip> <port>
pkill ncat
```


```
conntrack -D -p tcp -d 192.168.8.26 --dport 8300
conntrack -D -p tcp -d 192.168.8.26

```
stateful firewall 有狀態防火牆，會記住之前流量放行