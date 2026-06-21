---
title: 常用指令 DSM
toc: true
date: 2026-06-19
---
find . -type l 找目前目錄下軟連結
unlink <軟連結名稱> 移除軟連結



## DSM 家目錄不同磁碟
![](Pasted%20image%2020260506223910.png)


![](Pasted%20image%2020260506223918.png)


## scrutiny
先用SSH連線以fdisk -l查看硬碟代號，例硬碟在sde則寫為 - /dev/sde:/dev/sde
`
```yaml
services:
  scrutiny:
    container_name: scrutiny
    image: ghcr.io/analogj/scrutiny:master-omnibus
    cap_add:
      - SYS_RAWIO
      - SYS_ADMIN
    ports:
      - 6090:8080/tcp # webapp
      - 8086:8086/tcp # influxDB admin
    volumes:
      - /run/udev:/run/udev:ro
      - /volume1/docker/scrutiny:/opt/scrutiny/config
      - /volume1/docker/scrutiny/influxdb:/opt/scrutiny/influxdb
    devices:
      - /dev/nvme0n1:/dev/nvme0n1
      - /dev/nvme1n1:/dev/nvme1n1
      - /dev/sata1:/dev/sata1
      - /dev/sde:/dev/sde
    environment:
      - SCRUTINY_WEB_INFLUXDB_TOKEN=ANYLONGSTRING
      - SCRUTINY_WEB_INFLUXDB_INIT_USERNAME=A-USERNAME
      - SCRUTINY_WEB_INFLUXDB_INIT_PASSWORD=A-PASSWORD
      - COLLECTOR_CRON_SCHEDULE=0 23 * * *
    network_mode: synobridge
    security_opt:
      - no-new-privileges:true
    restart: unless-stopped
```




## OliveTin


## Vaultwarden
```yaml
version: "3"
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    ports:
     - 9445:80 #map any custom port to use (replace 9445 not 80)
    volumes:
     - ./data:/data:rw
    #environment:
#     - ROCKET_TLS={certs="/ssl/certs/certs.pem",key="/ssl/private/key.pem"}  // Environment variable is specific to the Rocket web server
     #- ADMIN_TOKEN=${ADMIN_TOKEN}
     #- WEBSOCKET_ENABLED=true
     #- SIGNUPS_ALLOWED=false
     #- SMTP_HOST=${SMTP_HOST}
     #- SMTP_FROM=${SMTP_FROM}
     #- SMTP_PORT=${SMTP_PORT}
     #- SMTP_SSL=${SMTP_SSL}
     #- SMTP_USERNAME=${SMTP_USERNAME}
     #- SMTP_PASSWORD=${SMTP_PASSWORD}
     #- DOMAIN=${DOMAIN}
```

## glance
```yaml
services:
  glance:
    container_name: glance
    network_mode: bridge
    image: glanceapp/glance
    volumes:
      - ./glance:/app/assets
      - ./glance.yml:/app/glance.yml
      - /etc/TZ:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 2020:8080
    restart: always
```

## OpenSpeedtest
```
version: '3.3'
services:
    speedtest:
        restart: unless-stopped
        container_name: openspeedtest
        network_mode: bridge
        ports:
            - '1030:3000'
            - '1031:3001'
        image: openspeedtest/latest
```


## portainer

```
services:
  portainer:
    container_name: portainer
    image: portainer/portainer-ce:sts
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./portainer_data:/data
    ports:
      - 9443:9443
      - 8000:8000  # Remove if you do not intend to use Edge Agents
```


```yaml
version: '3.8'
services:
  bark-server:
    image: finab/bark-server
    container_name: bark-server
    restart: always
    volumes:
      - ./data:/data
    ports:
      - "8090:8080"  # 左边的8090可以自行修改成服务器上没有使用的端口
  code-server:
    image: lscr.io/linuxserver/code-server:latest
    container_name: code-server
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - PASSWORD=password #optional
      - HASHED_PASSWORD= #optional
      - SUDO_PASSWORD=password #optional
      - SUDO_PASSWORD_HASH= #optional
      - PROXY_DOMAIN=code-server.my.domain #optional
      - DEFAULT_WORKSPACE=/config/workspace #optional
    volumes:
      - /path/to/code-server/config:/config
    ports:
      - 8443:8443
    restart: unless-stopped
  feishin:
    container_name: feishin
    image: 'ghcr.io/jeffvli/feishin:latest'
    environment:
      - SERVER_NAME=navidrome
      - SERVER_LOCK=true
      - SERVER_TYPE=navidrome
      - SERVER_URL=https://nd.xdn.duckdns.org
      - PUID=1000
      - PGID=1000
      - UMASK=002
      - TZ=America/Los_Angeles
    ports:
      - 9180:9180
    restart: unless-stopped
  heimdall:
    image: lscr.io/linuxserver/heimdall:latest
    container_name: heimdall
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/heimdall/config:/config
    ports:
      - 1330:80
      - 1320:443
    restart: unless-stopped
  homarr:
    container_name: homarr
    image: ghcr.io/ajnart/homarr:latest
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock # Optional, only if you want docker integration
      - ./docker/homarr/configs:/app/data/configs
      - ./docker/homarr/icons:/app/public/icons
      - ./docker/homarr/data:/data
    ports:
      - 7575:7575
  homer:
    image: b4bz/homer:latest
    container_name: homer
    restart: unless-stopped
    network_mode: bridge
    environment:
      - PUID=1000
      - PGID=100
      - TZ=Asia/Taipei
    volumes:
      - /docker/share/Container/homer/assets:/www/assets
    ports:
      - 5007:8080
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: npm
    restart: unless-stopped
    ports:
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81' # Admin Web Port
    volumes:
      - ./docker/npm/data:/data
      - ./docker/npm/letsencrypt:/etc/letsencrypt
   speedtest:
       restart: unless-stopped
       container_name: openspeedtest
       ports:
           - '3000:3000'
           - '3001:3001'
       image: openspeedtest/latest
  snapdrop:
    image: lscr.io/linuxserver/snapdrop:latest
    container_name: snapdrop
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/snapdrop/config:/config
    ports:
      - 1080:80
      - 1043:443
    restart: unless-stopped

```


