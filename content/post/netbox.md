---
title: netbox
toc: true
date: 2026-07-12
---

```
# 激活 NetBox 的虛擬環境
source /opt/netbox/venv/bin/activate

# 使用 pip 安裝 netbox-proxbox
pip install netbox-proxbox
```

_(如果是使用 Docker 版本部署 NetBox，則需要將 `netbox-proxbox` 加入到 `plugin_requirements.txt` 中並重新 build 容器。)_

### 步驟 B：修改 NetBox 設定檔

編輯 NetBox 的 `configuration.py`（通常位於 `/opt/netbox/netbox/netbox/configuration.py`），將插件啟用：

```
PLUGINS = [
    'netbox_proxbox',
]

# 如果有需要，可以在這裡加入進階設定，通常預設即可
PLUGINS_CONFIG = {
    'netbox_proxbox': {},
}
```

### 步驟 C：執行資料庫遷移與重啟服務

安裝新插件後，需要更新 NetBox 的資料庫結構並重啟服務：
```
# 執行 Django 資料庫遷移
cd /opt/netbox/netbox/
python3 manage.py migrate

# 收集靜態檔案
python3 manage.py collectstatic --no-input

# 重啟 NetBox 服務
sudo systemctl restart netbox netbox-rq
```

## 升級

在LXC容器打上update 即可
升級會導致網頁進不去，因為schema升級
```
source /opt/netbox/venv/bin/activate 
cd /opt/netbox/netbox/ 
# 這一步會補上缺失的 validation_schema 欄位
python3 manage.py migrate
# 強制重新收集所有靜態檔案 
python3 manage.py collectstatic --no-input deactivate
deactivate

systemctl restart netbox netbox-rq
```
