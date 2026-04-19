---
title: Synology 系統安裝
date: 2026-03-02
toc: true
---
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