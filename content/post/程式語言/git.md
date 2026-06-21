---
title: git
toc: true
date: 2026-06-18
---

## 建立hugo
```
## 安裝hugo
choco install hugo-extended
## 建立新網站
hugo new site my-blog 
cd my-blog
## 創立新主題
git init
git submodule add https://github.com/nunocoracao/blowfish.git themes/blowfish
設定blowfish
xcopy /E /I themes\blowfish\config config
config/_default/hugo.toml >> theme = "blowfish"

## 建立新文章
hugo new posts/my-first-post.md

## 文章列表加入網頁選單
config/_default/menus.toml
[[main]]
  name = "全部文章" 
  pageRef = "posts" 
  weight = 10

## git 
git add . 
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/你的帳號/你的專案名稱.git

```


很多公司對於一個人不可以隨意創造分支(通常只有一個),不然會太亂，雲端由管理管專案分支

如果不小心放入300MB大檔案,檔名稱為null,不小心提交要排除
BFG Repo-Cleaner
```
brew install bfg
## 強制抹除名為 null 的檔案
bfg --delete-files null
## 強制進行垃圾回收（釋放空間）
git reflog expire --expire=now --all
git gc --prune=now --aggressive
## 強制推送
git push origin main -f
```

加入`.gitignore` 忽略追蹤檔案
```
git rm -r --cached .obsidian/ 
git add . 
git commit -m "Remove .obsidian from tracking"
```





分離

雲端覆蓋本地
git fetch //抓雲端版本
git reset --hard origin/main

本地推覆蓋雲端(確定雲端舊)
git push --force
改之前commit
再改之前記得git pull git reset --hard HEAD^ git pull
git pull origin main
git push origin --delete branch-1 //本地刪除遠端分支






```
root@linux2:/# git config --global user.name ehur4k
root@linux2:/# git config --global user.email hastggttr@gmail.com
root@linux2:/# pwd
root@linux2:/# cd /root
root@linux2:~/linuxconf# git init
root@linux2:~/linuxconf# ls -Ra
root@linux2:~/linuxconf# vi hosts        //查看檔案狀態
root@linux2:~/linuxconf# git status
root@linux2:~/linuxconf# git add hosts   //加入檔案變成追蹤狀態

root@linux2:~/linuxconf# git status   
位於分支 master

尚無提交

要提交的變更：
  （使用 "git rm --cached <檔案>..." 以取消暫存）
	新檔案：   hosts

root@linux2:~/linuxconf# git commit -m "host v1"     //提交要有檔案說明
[master (根提交) 539c14c] host v1
 1 file changed, 1 insertion(+)
 create mode 100644 hosts
 
root@linux2:~/linuxconf# git status
位於分支 master
沒有要提交的檔案，工作區為乾淨狀態

root@linux2:~/linuxconf# vi hosts
root@linux2:~/linuxconf# git status
位於分支 master
尚未暫存以備提交的變更：
  （使用 "git add <檔案>..." 更新要提交的內容）
  （使用 "git restore <檔案>..." 捨棄工作區的改動）
	修改：     hosts

修改尚未加入提交（使用 "git add" 和/或 "git commit -a"）

root@linux2:~/linuxconf# git commit -am "host v2"
[master 4cb0267] host v2
 1 file changed, 2 insertions(+), 1 deletion(-)
 
 

root@linux2:~/linuxconf# git log               ;查看分支狀態
commit 4cb02674c03dee6f50b0b7d84e12d987a1d055af (HEAD -> master)
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:30:57 2025 +0800

    host v2

commit 539c14c6d048412d255543b1c7e863ef75115155
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:25:50 2025 +0800

    host v1


root@linux2:~/linuxconf# git diff 4cb0 539c        ;1版跟2版比較差異
diff --git a/hosts b/hosts
index 611d065..0ca1816 100644
--- a/hosts
+++ b/hosts
@@ -1,2 +1 @@
-192.168.80.50 pin.loca
-192,168.80.80 pin2.local
+192.168.80.50 pin.local


root@linux2:~/linuxconf# git diff 539c 4cb0      ;2版比1版比較差異
diff --git a/hosts b/hosts
index 0ca1816..611d065 100644
--- a/hosts
+++ b/hosts
@@ -1 +1,2 @@
-192.168.80.50 pin.local
+192.168.80.50 pin.loca
+192,168.80.80 pin2.local

root@linux2:~/linuxconf# git remote add origin https://github.com/ehur4k/linuxconf.git
root@linux2:~/linuxconf# git remote -v 
origin	https://github.com/ehur4k/linuxconf.git (fetch)
origin	https://github.com/ehur4k/linuxconf.git (push)
root@linux2:~/linuxconf# git branch
* master
root@linux2:~/linuxconf# gut branch -M main 
bash: gut: 找不到指令...
root@linux2:~/linuxconf# git branch -M main 
root@linux2:~/linuxconf# git branch
* main

:: 推上去
root@linux2:~/linuxconf# git push -u origin main
Username for 'https://github.com': ehur4k
Password for 'https://ehur4k@github.com': 
枚舉物件: 6, 完成.
物件計數中: 100% (6/6), 完成.
使用 4 個執行緒進行壓縮
壓縮物件中: 100% (2/2), 完成.
寫入物件中: 100% (6/6), 461 位元組 | 461.00 KiB/s, 完成.
總共 6 (差異 0)，復用 0 (差異 0)，重用包 0 (總共 0)
To https://github.com/ehur4k/linuxconf.git
 * [new branch]      main -> main
已將「main」分支設定為追蹤「origin/main」。

::推上去之前儲存認證免得一直重打
root@linux2:~/linuxconf# git config --global credential.helper store
root@linux2:~/linuxconf# git push 
Username for 'https://github.com': ehur4k
Password for 'https://ehur4k@github.com': 
Everything up-to-date
root@linux2:~/linuxconf# vi hosts
root@linux2:~/linuxconf# vi /etc/hosts
root@linux2:~/linuxconf# vi hosts
root@linux2:~/linuxconf# git add hosts
root@linux2:~/linuxconf# git commit -m "host v3" 
[main 35bbb4e] host v3
 1 file changed, 1 insertion(+)
root@linux2:~/linuxconf# git status
位於分支 main
您的分支領先 'origin/main' 共 1 個提交。
  （使用 "git push" 來發布您的本機提交）

沒有要提交的檔案，工作區為乾淨狀態
root@linux2:~/linuxconf# git log
commit 35bbb4ecdccdd5aa40fe38788a166dcfb6cc56b4 (HEAD -> main)
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 12:00:49 2025 +0800

    host v3

commit 4cb02674c03dee6f50b0b7d84e12d987a1d055af (origin/main)
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:30:57 2025 +0800

    host v2

commit 539c14c6d048412d255543b1c7e863ef75115155
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:25:50 2025 +0800

    host v1
root@linux2:~/linuxconf# git push
枚舉物件: 5, 完成.
物件計數中: 100% (5/5), 完成.
使用 4 個執行緒進行壓縮
壓縮物件中: 100% (2/2), 完成.
寫入物件中: 100% (3/3), 276 位元組 | 276.00 KiB/s, 完成.
總共 3 (差異 0)，復用 0 (差異 0)，重用包 0 (總共 0)
To https://github.com/ehur4k/linuxconf.git
   4cb0267..35bbb4e  main -> main




::檢視log版本
root@linux2:~/linuxconf# git reflog
35bbb4e (HEAD -> main, origin/main) HEAD@{0}: commit: host v3
4cb0267 HEAD@{1}: Branch: renamed refs/heads/master to refs/heads/main
4cb0267 HEAD@{3}: commit: host v2
539c14c HEAD@{4}: commit (initial): host v1
root@linux2:~/linuxconf# git show 4cb0267:hosts
192.168.80.50 pin.loca
192,168.80.80 pin2.local

::
root@linux2:~/linuxconf# vi hosts
root@linux2:~/linuxconf# git commit -am "host v4"
[main 9901de2] host v4
 1 file changed, 1 insertion(+)
root@linux2:~/linuxconf# git log
commit 9901de2caef4a3b9b2e2f1a4e093caea3c9ba087 (HEAD -> main)
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 13:31:11 2025 +0800

    host v4

commit 35bbb4ecdccdd5aa40fe38788a166dcfb6cc56b4 (origin/main)
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 12:00:49 2025 +0800

    host v3

commit 4cb02674c03dee6f50b0b7d84e12d987a1d055af
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:30:57 2025 +0800

    host v2

commit 539c14c6d048412d255543b1c7e863ef75115155
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:25:50 2025 +0800

    host v1
root@linux2:~/linuxconf# git reset --soft HEAD^
root@linux2:~/linuxconf# git status
位於分支 main
您的分支與上游分支 'origin/main' 一致。

要提交的變更：
  （使用 "git restore --staged <檔案>..." 以取消暫存）
	修改：     hosts

root@linux2:~/linuxconf# git commit -am "host v4"
[main 7cc90d8] host v4
 1 file changed, 1 insertion(+)
root@linux2:~/linuxconf# git reflog
7cc90d8 (HEAD -> main) HEAD@{0}: commit: host v4
35bbb4e (origin/main) HEAD@{1}: reset: moving to HEAD^
9901de2 HEAD@{2}: commit: host v4
35bbb4e (origin/main) HEAD@{3}: commit: host v3
4cb0267 HEAD@{4}: Branch: renamed refs/heads/master to refs/heads/main
4cb0267 HEAD@{6}: commit: host v2
539c14c HEAD@{7}: commit (initial): host v1
root@linux2:~/linuxconf# git commit -m "host v4"
位於分支 main
您的分支領先 'origin/main' 共 1 個提交。
  （使用 "git push" 來發布您的本機提交）

沒有要提交的檔案，工作區為乾淨狀態
root@linux2:~/linuxconf# git reset --mixed HEAD^
重設後取消暫存的變更：
M	hosts
root@linux2:~/linuxconf# git status
位於分支 main
您的分支與上游分支 'origin/main' 一致。

尚未暫存以備提交的變更：
  （使用 "git add <檔案>..." 更新要提交的內容）
  （使用 "git restore <檔案>..." 捨棄工作區的改動）
	修改：     hosts

修改尚未加入提交（使用 "git add" 和/或 "git commit -a"）
root@linux2:~/linuxconf# git commt -am "host v4"
git：'commt' 不是一個 git 指令。參見 'git --help'。

最類似的指令有
	commit
root@linux2:~/linuxconf# git commit -am "host v4"
[main 156fe77] host v4
 1 file changed, 1 insertion(+)
root@linux2:~/linuxconf# git reset --hard HEAD^
HEAD 現在位於 35bbb4e host v3
root@linux2:~/linuxconf# git log
commit 35bbb4ecdccdd5aa40fe38788a166dcfb6cc56b4 (HEAD -> main, origin/main)
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 12:00:49 2025 +0800

    host v3

commit 4cb02674c03dee6f50b0b7d84e12d987a1d055af
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:30:57 2025 +0800

    host v2

commit 539c14c6d048412d255543b1c7e863ef75115155
Author: ehur4k <hastggttr@gmail.com>
Date:   Fri Dec 5 11:25:50 2025 +0800

    host v1




root@linux2:~/linuxconf# git merge test   //合併分支
root@linux2:~/linuxconf# git branch -d test  //合併後刪除分支(用於合併，不合併無法刪)
root@linux2:~/linuxconf# git branch
root@linux2:~/linuxconf# git checkout -b branch1  //創造分支branch1並切換過去
root@linux2:~/linuxconf# cp /etc/NetworkManager/system-connections/ens160.nmconnection /root/linuxconf
root@linux2:~/linuxconf# ls
root@linux2:~/linuxconf# git add --all
root@linux2:~/linuxconf# git commit -m "host v5"
root@linux2:~/linuxconf# git status
root@linux2:~/linuxconf# git checkout -b banch2 
root@linux2:~/linuxconf# cat hosts
root@linux2:~/linuxconf# git checkout banch2  //切換至banch2

root@linux2:~/linuxconf# git add hosts
root@linux2:~/linuxconf# git commit -m "host v5"
[banch2 d3bd952] host v5
 1 file changed, 2 insertions(+), 1 deletion(-)
root@linux2:~/linuxconf# git checkout main
已切換至分支「main」
您的分支與上游分支 'origin/main' 一致。
root@linux2:~/linuxconf# git merge banch2
自動合併 hosts
衝突（內容）：合併衝突於 hosts
自動合併失敗，修正衝突然後提交修正的結果。
root@linux2:~/linuxconf# cat hosts
192.168.80.50 pin.loca
192,168.80.80 pin2.local
192.168.80.30 pin3.local
192.167.46.64 pins.lovsl
<<<<<<< HEAD
=======
192.166.66.66 pins.local
18.155.32.12 pin.local
>>>>>>> banch2
root@linux2:~/linuxconf# vi hosts
root@linux2:~/linuxconf# git add hosts
root@linux2:~/linuxconf# git commit -m "host v5 and 6"
[main e64e306] host v5 and 6
root@linux2:~/linuxconf# git status
位於分支 main
您的分支領先 'origin/main' 共 5 個提交。
  （使用 "git push" 來發布您的本機提交）

沒有要提交的檔案，工作區為乾淨狀態
root@linux2:~/linuxconf# git push
枚舉物件: 18, 完成.
物件計數中: 100% (18/18), 完成.
使用 4 個執行緒進行壓縮
壓縮物件中: 100% (13/13), 完成.
寫入物件中: 100% (14/14), 1.48 KiB | 1.48 MiB/s, 完成.
總共 14 (差異 3)，復用 0 (差異 0)，重用包 0 (總共 0)
remote: Resolving deltas: 100% (3/3), completed with 1 local object.
To https://github.com/ehur4k/linuxconf.git
   485f88a..e64e306  main -> main
root@linux2:~/linuxconf# git reflog



```