---
title: Peertube 架設
toc: true
date: 2026-04-19
---
1. 編寫 Docker-Compose，要注意db裡面的hostname要跟env一致才能連線,接者使用Portainer.io編寫yaml檔
```
services:
  redis:
    image: redis:7
    command: redis-server --requirepass redispass
    container_name: PeerTube-redis
    hostname: peertube-redis
    security_opt:
      - no-new-privileges:true
    read_only: true
    user: 1026:100
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping || exit 1"]
    volumes:
      - /volume1/docker/peertube/redis:/data:rw
    environment:
      TZ: Europe/Bucharest
    restart: on-failure:5

  db:
    image: postgres:18
    container_name: PeerTube-DB
    hostname: peertube-db
    security_opt:
      - no-new-privileges:true
    healthcheck:
      test: ["CMD", "pg_isready", "-q", "-d", "$POSTGRES_DB", "-U", "$POSTGRES_USER"]
      timeout: 45s
      interval: 10s
      retries: 10
    volumes:
      - /volume1/docker/peertube/db:/var/lib/postgresql:rw
    env_file:
      - stack.env
    restart: on-failure:5

  peertube:
    image: chocobozzz/peertube:production
    container_name: PeerTube
    hostname: peertube
    security_opt:
      - no-new-privileges:true
    healthcheck:
      test: curl -f http://localhost:9000/ || exit 1
    ports:
      - 1935:1935 # Comment if you don't want to use the live feature
      - 9510:9000
    volumes:
      - /volume1/docker/peertube/data:/data:rw
      - /volume1/docker/peertube/config:/config:rw
    env_file:
      - stack.env
    restart: on-failure:5
    depends_on:
      redis:
        condition: service_healthy
      db:
        condition: service_healthy
```
2. stack.env,在Portainer.io上傳stack.env的檔案,在繼續修改
```
# Database / Postgres service configuration
POSTGRES_USER=<MY POSTGRES USERNAME>
POSTGRES_PASSWORD=<MY POSTGRES PASSWORD>
# Postgres database name "peertube"
POSTGRES_DB=peertube
# The database name used by PeerTube will be PEERTUBE_DB_NAME (only if set) *OR* 'peertube'+PEERTUBE_DB_SUFFIX
#PEERTUBE_DB_NAME=<MY POSTGRES DB NAME>
#PEERTUBE_DB_SUFFIX=_prod
# Database username and password used by PeerTube must match Postgres', so they are copied:
PEERTUBE_DB_USERNAME=$POSTGRES_USER
PEERTUBE_DB_PASSWORD=$POSTGRES_PASSWORD
PEERTUBE_DB_SSL=false
# Default to Postgres service name "postgres" in docker-compose.yml
PEERTUBE_DB_HOSTNAME=peertube-db

# PeerTube server configuration
# If you test PeerTube in local: use "peertube.localhost" and add this domain to your host file resolving on 127.0.0.1
PEERTUBE_WEBSERVER_HOSTNAME=<MY DOMAIN>
# If you just want to test PeerTube on local
#PEERTUBE_WEBSERVER_PORT=9000
#PEERTUBE_WEBSERVER_HTTPS=false
# If you need more than one IP as trust_proxy
# pass them as a comma separated array:
PEERTUBE_TRUST_PROXY=["127.0.0.1", "loopback", "172.18.0.0/16"]

# Generate one using `openssl rand -hex 32`
PEERTUBE_SECRET=<MY PEERTUBE SECRET>

# E-mail configuration
# If you use a Custom SMTP server
#PEERTUBE_SMTP_USERNAME=
#PEERTUBE_SMTP_PASSWORD=
# Default to Postfix service name "postfix" in docker-compose.yml
# May be the hostname of your Custom SMTP server
PEERTUBE_SMTP_HOSTNAME=postfix
PEERTUBE_SMTP_PORT=25
PEERTUBE_SMTP_FROM=noreply@<MY DOMAIN>
PEERTUBE_SMTP_TLS=false
PEERTUBE_SMTP_DISABLE_STARTTLS=false
PEERTUBE_ADMIN_EMAIL=<MY EMAIL ADDRESS>

# Postfix service configuration
POSTFIX_myhostname=<MY DOMAIN>
# If you need to generate a list of sub/DOMAIN keys
# pass them as a whitespace separated string <DOMAIN>=<selector>
OPENDKIM_DOMAINS=<MY DOMAIN>=peertube
# see https://github.com/wader/postfix-relay/pull/18
OPENDKIM_RequireSafeKeys=no

# If you want to enable object storage for PeerTube, set the following variables.
#PEERTUBE_OBJECT_STORAGE_ENABLED=
#PEERTUBE_OBJECT_STORAGE_ENDPOINT=
#PEERTUBE_OBJECT_STORAGE_REGION=
#PEERTUBE_OBJECT_STORAGE_FORCE_PATH_STYLE=
#PEERTUBE_OBJECT_STORAGE_CREDENTIALS_ACCESS_KEY_ID=
#PEERTUBE_OBJECT_STORAGE_CREDENTIALS_SECRET_ACCESS_KEY=
#PEERTUBE_OBJECT_STORAGE_STREAMING_PLAYLISTS_BUCKET_NAME=
#PEERTUBE_OBJECT_STORAGE_STREAMING_PLAYLISTS_PREFIX=
#PEERTUBE_OBJECT_STORAGE_STREAMING_PLAYLISTS_BASE_URL=
#PEERTUBE_OBJECT_STORAGE_WEB_VIDEOS_BUCKET_NAME=
#PEERTUBE_OBJECT_STORAGE_WEB_VIDEOS_PREFIX=
#PEERTUBE_OBJECT_STORAGE_WEB_VIDEOS_BASE_URL=
#PEERTUBE_OBJECT_STORAGE_USER_EXPORTS_BUCKET_NAME=
#PEERTUBE_OBJECT_STORAGE_USER_EXPORTS_PREFIX=
#PEERTUBE_OBJECT_STORAGE_USER_EXPORTS_BASE_URL=
#PEERTUBE_OBJECT_STORAGE_ORIGINAL_VIDEO_FILES_BUCKET_NAME=
#PEERTUBE_OBJECT_STORAGE_ORIGINAL_VIDEO_FILES_PREFIX=
#PEERTUBE_OBJECT_STORAGE_ORIGINAL_VIDEO_FILES_BASE_URL=
#PEERTUBE_OBJECT_STORAGE_CAPTIONS_BUCKET_NAME=
#PEERTUBE_OBJECT_STORAGE_CAPTIONS_PREFIX=
#PEERTUBE_OBJECT_STORAGE_CAPTIONS_BASE_URL=

# Comment these variables if your S3 provider does not support object ACL
PEERTUBE_OBJECT_STORAGE_UPLOAD_ACL_PUBLIC="public-read"
PEERTUBE_OBJECT_STORAGE_UPLOAD_ACL_PRIVATE="private"

#PEERTUBE_LOG_LEVEL=info

# /!\ Prefer to use the PeerTube admin interface to set the following configurations /!\
#PEERTUBE_SIGNUP_ENABLED=true
#PEERTUBE_TRANSCODING_ENABLED=true
#PEERTUBE_CONTACT_FORM_ENABLED=true
```
3. 因為安裝起來會有Otah 2.0強制走https驗證會無法登入問題,要先把config寫在production.yaml讓PeerTube才能登入
```
webserver:
  hostname: '192.168.8.104'
  port: 9510
  https: false
```



## 參考資料
- https://mariushosting.com/how-to-install-peertube-on-your-synology-nas/