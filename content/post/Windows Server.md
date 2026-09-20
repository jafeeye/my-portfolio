---
---

## 安裝優化
1. 關閉密碼到期
```
Import-Module ActiveDirectory

Set-ADUser -Identity $env:USERNAME `
  -PasswordNeverExpires $true `
  -ChangePasswordAtLogon $false
```


移除DC控制器
```
$localPassword = Read-Host "2Password!" -AsSecureString

Uninstall-ADDSDomainController `
  -ForceRemoval `
  -DemoteOperationMasterRole `
  -LocalAdministratorPassword $localPassword `
  -Force
```



![gh](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1746685385000y42kg8.png)
