#### 1.下載特定版本docker鏡像
  ![](https://raw.githubusercontent.com/jafeeye/imglib/refs/heads/main/Pasted%20image%2020241102120546.png)

```bash
docker pull neilpang/acme.shacme.sh
docker run -it  \
    --net=host \
    --name=acme \
    -v /volume2/docker/acme:/acme.sh  \
    -e SYNO_Username= \
    -e SYNO_Password= \     
    -e SYNO_Certificate="" \
    -e CF_Zone_ID= \
    -e CF_Token_ID= \ 
    neilpang/acme.sh:3.0.6  daemon
```

-d: 后台运行容器并返回容器 ID。
-it: 交互式运行容器，分配一个伪终端。
--name: 给容器指定一个名称。
-p: 端口映射，格式为 host_port:container_port。
-v: 挂载卷，格式为 host_dir:container_dir。
--rm: 容器停止后自动删除容器。
--env 或 -e: 设置环境变量。
--network: 指定容器的网络模式。
--restart: 容器的重启策略（如 no、on-failure、always、unless-stopped）。
-u: 指定用户
 daemon 守護進程
#### DuckDNS
![[Pasted image 20241110205433.png]]
### 更改默認簽發機構為 Let's Encrypt
acme.sh 被商業收購收購，目前預設使用ZeroSSL，在docker更改要加上指令
`docker exec -it acme --set-default-ca --server letsencrypt
### Cloudflare域名参数



#### 編寫自動更新腳本

```bash
#!/bin/bash 
docker exec neilpang-acme.sh1 acme.sh --force --log --issue --server letsencrypt --dns dns_cf --dnssleep 120 -d example.com -d *.example.com -k 4096
docker exec neilpang-acme.sh1 acme.sh --deploy -d example.com -d *.example.com --deploy-hook synology_dsm
```

### 建立群暉排程


### 參考資料

主要資料
[使用Docker搭建acme.sh签发群晖DSM的ssl证书](https://blog.mstg.top/archives/957)
延伸資料 
[使用docker安裝acme.sh並手動申請泛域名證書](https://www.sio.moe/2021/12/18/computer/Docker-Container/Use-Docker-install-acme-sh-and-manually-apply-for-a-pan-domain-certificate/)
[群晖DSM7.x通过acme.sh全自动更新并部署SSL证书](https://blog.zakikun.com/archives/80.html)