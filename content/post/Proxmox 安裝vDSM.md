---
title: Proxmox 安裝 vDSM
toc: true
date: 2026-10-26
tags:
  - PVE
  - DSM
  - OS安裝
  - NAS
---
## vDSM LXC
1. 執行LXC腳本,設定容器權限
- bash -c "$(wget -qLO - https://raw.githubusercontent.com/databreach/virtual-dsm-lxc/main/virtual-dsm-lxc-gpu.sh)"
- Enter the LXC Container ID of the container created above (e.g. `101`).
- Enter the GPU / vGPU card ID (e.g. for card1 you would enter `1`).
- Enter the GPU / vGPU renderD ID (e.g. for renderD129 you would enter `129`).

2. Install Docker and run virtual-dsm
- Start the LXC Container created above and login to its console via the Proxmox UI or SSH.
- Install sudo、curl、Docker 
  `apt update && apt install -y curl sudo`
  `curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh 
- Run virtual-dsm in docker using the mount points created: `docker run -it --rm -p 5000:5000 --cap-add NET_ADMIN --device-cgroup-rule='c *:* rwm' --sysctl net.ipv4.ip_forward=1 --device /dev/net/tun --device /dev/kvm --device /dev/vhost-net --device /dev/dri --stop-timeout 60 -v /vdsm/storage1:/storage -v /vdsm/storage2:/storage2 -e CPU_CORES=2 -e RAM_SIZE=4096M -e DISK_SIZE=16G -e DISK2_SIZE=2T -e DISK_FMT=qcow2 -e ALLOCATE=N -e GPU=Y vdsm/virtual-dsm:latest`

2. AI 改的
```
docker run -d \
  --name vdsm \
  --restart always \
  -p 5000:5000 \
  --cap-add NET_ADMIN \
  --device-cgroup-rule='c *:* rwm' \
  --sysctl net.ipv4.ip_forward=1 \
  --device /dev/net/tun \
  --device /dev/kvm \
  --device /dev/vhost-net \
  --stop-timeout 60 \
  -v /vdsm/storage1:/storage \
  -v /vdsm/storage2:/storage2 \
  -e CPU_CORES=2 \
  -e RAM_SIZE=4096M \
  -e DISK_SIZE=16G \
  -e DISK2_SIZE=2T \
  -e DISK_FMT=qcow2 \
  -e ALLOCATE=N \
  -e GPU=N \
  vdsm/virtual-dsm:latest
```

### 其他參數
- Replaced `-e ALLOCATE=N` with new disk feature `-e DISK_FMT=qcow2`.
- Re-added `-e ALLOCATE=N` to be used in combination with qcow2.
- Removed obsolete `DEV=N` parameter.

Docker套娃，設定群暉Docker服務
```shell
vi /var/packages/ContainerManager/etc/dockerd.json
systemctl daemon-reload
systemctl restart pkg-ContainerManager-dockerd
```

https://github.com/vdsm/virtual-dsm/issues/382
參考影片：https://www.youtube.com/watch?v=LKZKsyZULYM