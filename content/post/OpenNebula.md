
一開始就要創特權容器，不然之後改回來會出現裝不上去問題

```
lxc.cgroup2.devices.allow: c 10:200 rwm 
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
features: nesting=1 
privileged: 1
```

apt install augeas-tools curl bridge-utils

```
#1. 讓殘留的網卡強制離線
ip link set dev minionebr down 2>/dev/null
#2. 彻底刪除這個網卡（這會連帶沖刷掉 172.16.100.0/24 的路由）
ip link delete dev minionebr 2>/dev/null
```

如果一直出現錯誤，開機再重新執行一次就可以解決


`./minione --force`
