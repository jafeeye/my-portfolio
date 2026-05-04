
先使用Docker-Compose 部屬容器

\*記得Config.yml一定要儲存成UTF-8，不然容器會報錯無法啟動

進入Docker容器安裝sshpass
```bash
docker exec -it --user root olivetin /bin/bash
microdnf update -y
microdnf install sshpass -y
```
一開始先進入容器使用ssh 使用者@IP 登入，讓他記住憑證
```bash
sshpass -p 密碼 ssh PIN@192.168.8.249 'ping www.google.com -c 4'
sshpass -p 密碼 ssh root@192.168.8.80 'shutdown'
sshpass -p 密碼 ssh root@192.168.8.120 'shutdown -h now'
```
#### macOS 啟用root權限編輯

1. 使用 Spotlight 尋找並打開「目錄工具程式」，或按照下列步驟操作：
- 從 Finder 中的選單列選擇「前往」&gt;「前往檔案夾」。
- 輸入或貼上 /System/Library/CoreServices/Applications/，然後按下 Return 鍵。
- 從開啟的視窗中打開「目錄工具程式」。
- 若要啟用 root 使用者，請從選單列選擇「編輯」&gt;「啟用根使用者」，然後輸入你要使用的密碼。這時你就能以 root 使用者身分登入。
2. 編輯 /private/etc/ssh/sshd\_config/sshd\_config 並加入PermitRootLogin yes
3. 重啟ssh服務（等於linuxsudo service ssh restart）

```bash
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist 
```


#### 參考資料

https://laosu.tech/2022/07/06/OliveTin%E8%83%BD%E5%9C%A8%E7%BD%91%E9%A1%B5%E4%B8%8A%E5%AE%89%E5%85%A8%E8%BF%90%E8%A1%8Cshell%E5%91%BD%E4%BB%A4%EF%BC%88%E4%B8%8A%EF%BC%89/?highlight=olivetin。

我不是咕咕鸽，https://blog.laoda.de/。

老苏的blog，https://laosu.tech/。