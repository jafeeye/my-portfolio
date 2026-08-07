---
title: docker
toc: true
date: 2026-06-21
---
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



docker ps 
docker logs <容器名稱>
Arcane
![](static/Pasted%20image%2020260719123345.png)
Portainer
![](static/Pasted%20image%2020260719123134.png)