---
title: docker
toc: true
date: 2026-06-21
---
docker ps 
docker logs <容器名稱>
Arcane
![](static/Pasted%20image%2020260719123345.png)
## Portainer
![](static/Pasted%20image%2020260719123134.png)
LXC 安裝方式
```
sudo docker volume create portainer_data

sudo docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```
改連線過去IP
![](static/Pasted%20image%2020260825152303.png)


重啟加參數
```
sudo docker stop portainer
sudo docker rm portainer

sudo docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest \
  --trusted-origins portainer.bd1.dev
```
