---
title: OpenShift 教學
toc: true
date: 2026-05-23
---
1. 單機環境 -> 有的，裝 [Red Hat OpenShift Local (formerly Red Hat CodeReady Containers)](https://www.redhat.com/en/blog/codeready-containers) / 以前的名字叫做 CRC ... 現在叫做 OpenShift Local。
2. 自建**免費叢集** -> 社群版 [OKD](https://github.com/okd-project/okd)。
3. 自建**試用叢集** -> 試用版，要去註冊 Hed Hat 帳號，並申請試用 OCP。

現在安裝方法除了麻煩的離線安裝,也可以到RedHat網站直接生成OKD映像直接安裝
### 1. 下載 OpenShift 核心安裝工具

```
# 下載 OKD 專用的安裝二進位檔 (以目前的穩定版為例)
wget https://github.com/okd-project/okd/releases/download/4.13.0-0.okd-2023-06-04-080300/openshift-install-linux-4.13.0-0.okd-2023-06-04-080300.tar.gz
tar -xvf openshift-install-linux-*.tar.gz
mv openshift-install /usr/local/bin/
```

### 2. 下載組態轉換工具（Butane）

紅帽的作業系統不讀 YAML，只讀 JSON 格式的 Ignition。我們需要 `butane` 工具來幫我們做格式轉換：
```
wget https://github.com/coreos/butane/releases/download/v0.19.0/butane-amd64 -O /usr/local/bin/butane
chmod +x /usr/local/bin/butane
```

## 核心步驟一：編寫並生成本地 Ignition 檔案

### 1. 建立工作目錄並撰寫基礎配置

建立一個 `install-config.yaml` 檔案：
```
mkdir okd-install && cd okd-install
vi install-config.yaml
```
貼入以下內容（這是單節點 SNO 最精簡的本地宣告）：
```yaml
apiVersion: v1
baseDomain: myk8s.local
compute:
- name: worker
  replicas: 0 # SNO 模式下 Worker 設為 0
controlPlane:
  name: master
  replicas: 1
metadata:
  name: okd-sno
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OVNKubernetes # OKD 預設的 CNI
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {} # 代表生鐵/PVE 裸機環境
pullSecret: '{"auths":{"fake":{"auth":"ZXlK..."}}}' # 開源版可以放假的 JSON 串
sshKey: 'ssh-rsa AAAAB3NzaC1yc2E...' # 貼上你 Rocky Linux 的公鑰
```

### 2. 編譯出本機 Ignition 檔案

執行指令，這個工具會把上面的 YAML 檔案「撕碎」，吐出三個 JSON 檔案：
```
openshift-install create ignition-configs --dir=.
```

執行完後，目錄下會多出 `master.ign`、`worker.ign`、`bootstrap.ign`。因為我們是單節點 (SNO)，我們只需要 **`master.ign`**。

## 核心步驟二：在內網架設 HTTP 伺服器

因為 PVE 的虛擬機開機時，必須透過網路把剛剛生成的 `master.ign` 檔案讀進去。最快的方法是在你的 Rocky Linux 上用 Python 臨時開一個網頁伺服器：
```
# 在含有 master.ign 的目錄下執行，啟動一個 8080 埠口的 HTTP 服務
python3 -m http.server 8080
```

_這時，你的檔案網址就會是：`http://192.168.8.83:8080/master.ign`_

## 核心步驟三：Proxmox VE 建置與開機（黑客注入法）

1. **下載 FCOS 鏡像**：去 Fedora CoreOS 官網下載標準的 `.iso` 檔並放進 PVE。
2. **規格配置**：在 PVE 建立 VM（8 vCPU, 16GB RAM, 120GB 磁碟，CPU Type 設為 `host`）。
3. **開機掛載並攔截**：
    
    - 啟動 VM，當畫面上出現 **Fedora CoreOS 的 GRUB 開機選單**時，**立刻按下鍵盤的 `E` 鍵**進入編輯模式。
    - 找到帶有 `linux` 開頭的那一行字，在該行的最末端，空一格，手動輸入以下**注入指令**，告訴它去哪裡抓你的設定檔：
 
```
coreos.inst.install_dev=vda coreos.inst.ignition_url=http://192.168.8.83:8080/master.ign
```
    _(註：`vda` 是你虛擬機的硬碟代號，如果是 SATA 則改 `sda`)_    
    - 輸完後，按下 **`Ctrl + X`** 啟動。

## 收尾：看著它自我孵化

虛擬機讀取到你的 Python 伺服器上的 `master.ign` 後，就會開始格式化自己的硬碟，並自動下載 OpenShift 全套的 Container 元件。你可以回到 Rocky Linux 跳板機上，敲入這行指令來監控它到底蓋好了沒：
```
openshift-install --dir=. wait-for install-complete
```



RBAC（Role-Based Access Control，角色式存取控制）也是 Kubernetes 與 OpenShift 中最核心的權限管理機制

1. **Pod IP**
    
    - **說明：** 每個 Pod 啟動時，會由 CNI（Container Network Interface）分配一個獨立 IP，這個 IP 只在叢集中有效。
    - **用途：** Pod 之間直接通訊（例如 curl http://:8080）。
    - **指令：** `oc get pod <pod_name> -o wide`
        
        ```shell=
        NAME            IP             NODE
        mypod           10.128.54.87   worker-1
        ```
        
    
    > 誰可持有？ Pod。  
    > 誰看得到？ 同一座叢集中的 Pod。  
    > Pod 可以跨不同 namespace 和別的 Pod 溝通。
    
2. **Service IP (Cluster IP)**
    
    - **說明：** K8s Service 會建立一個「虛擬 IP」，供其他 Pod 存取，用於負載平衡 + 提供穩定接口。
    - **用途：** Pod → Service 通訊時使用，例如 `curl http://my-service:8080`
    - **指令：** `oc get svc my-service`
        
        ```shell=
        NAME         CLUSTER-IP      PORT(S)
        my-service   172.30.94.87    8080/TCP
        ```
        
    
    > 誰可持有？ Service。  
    > 誰看得到？ 同一 namespace 的 Pod。 / 同一座叢集中的 Pod。
    > 
    > > 相同 namespace 的 Pod 可直接訪問： `http://my-service`  
    > > 不同 namespace 的 Pod 要透過完整 DNS 存取： `http://<service-name>.<namespace>.svc.cluster.local`  
    > > 跨 namespace 的連線，需要透過 Kubernetes 中內建 DNS（如 CoreDNS）進行域名解析
    
    - 補充：

|名稱格式|說明|
|---|---|
|`my-svc`|同 namespace 使用|
|`my-svc.my-namespace`|不同 namespace 使用|
|`my-svc.my-namespace.svc`|更完整|
|`my-svc.my-namespace.svc.cluster.local`|完整 FQDN（fully qualified domain name）|

```
* 不過有例外 (不能訪問)
    1. 有設定 NetworkPolicy 限制跨 namespace 流量
    2. Service 沒有 selector（headless）
    3. Service port 沒有打開或錯誤
```

3. **Node IP**
    
    - **說明：** 執行 Pod 的 Node（實體主機或 VM）的 IP。
    - **用途：** 使用了 `NodePort 類型的 Service` / Debug 時需要知道（SSH、檢查網路）
    - **指令：** `oc get nodes -o wide`
        
        ```shell=
        NAME          INTERNAL-IP     EXTERNAL-IP
        worker-1      192.168.1.101   <none>
        ```
        
    
    > 誰可持有？ 各個節點 / Master Node / Worker Node  
    > 誰看得到？ 在允許的情況下...Pod 可以直接和節點溝通。
    
4. **External IP**
    
    - **說明：** Service 可綁定一個外部 IP（例如某台外部機器或網段的 IP），讓外部能直接連線。
    - **用途：** 指定 `External IP` 做為出口。 比較常見的是，使用了多個 Pod 處理了請求後，要讓請求者看起來，都是從特定 IP 丟回來的這樣的目的。
    - **配置方式**
        
        ```yaml=
        apiVersion: v1
        kind: Service
        metadata:
          name: my-service
        spec:
          type: ClusterIP
          selector:
            app: myapp
          externalIPs:
            - 203.0.113.50
          ports:
            - port: 80
              targetPort: 8080
        ```
        
5. **LoadBalancer IP**
    
    - **說明：** 當 Service type 設為 LoadBalancer，K8s 會請雲平台（如 AWS, GCP）建立一個對外的 Load Balancer 並分配 IP。
    - **用途：** 讓外部用戶從網際網路存取服務。
    - **指令：** `kubectl get svc my-service`
    
    ```shell=
    NAME         TYPE           EXTERNAL-IP     PORT(S)
    my-service   LoadBalancer   35.201.45.22    80:32112/TCP
    ```
    
6. **Ingress / Route IP**
    
    - **Ingress 說明：** Ingress 是一種 K8s 對外 HTTP 路由機制。
    - **Route 說明：** OpenShift 雖然也可以用 Ingress，但通常會直接使用 OCP 的 Route，透過 `*.apps.cluster.com` 之類的網域轉發。
    - **用途：** 將外部流量導向特定 Service（多路由、多 path）
    - **Ingress 指令：** `kubectl get ingress my-ingress`
        
        ```shell=
        NAME         HOSTS                     ADDRESS         PORTS
        my-ingress   myapp.example.com         34.123.45.6     80
        ```
        
    - **OCP 指令：** `oc get route myapp`
        
        ```shell=
        NAME    HOST/PORT                                SERVICE
        myapp   myapp.apps.cluster.local                 my-service
        ```
        
        > 對應到某個 Node 或 Router IP。
        
7. **Public IP**
    
    - **說明：** 實際可從外部網際網路（如你用電腦的 Chrome）存取的 IP，通常透過：LoadBalancer IP（雲平台自動分配）、Route 對應的 DNS（再指向 Node IP）、Ingress Controller 的 LB IP
    - **用途：** 讓用戶、瀏覽器、第三方系統能存取你的服務。
    - **指令：** `nslookup myapp.apps.cluster.local`

## DaemonSet

- 顧名思義，拿來作為 **Daemon (守護程序)**。
- 是 Kubernetes 的一種工作負載（Workload）資源，用來確保 **「每一個 Node 上都會執行一份指定的 Pod」**。
- 在叢集中，如果加入了「新的節點」，那麼叢集會自動、在這些節點中長出新的守程 Pod，刪除節點時自動移除。

### 常見的 DaemonSet

|用途|說明|範例|
|---|---|---|
|📋 日誌收集|在每台機器收集 container logs|`Fluentd`, `Filebeat`, `Logstash`|
|📊 監控代理|安裝監控 agent 到每個 Node|`Prometheus Node Exporter`, `Datadog Agent`|
|🔐 安全守衛|防火牆、容器安全工具|`Falco`, `Sysdig`|
|🌐 網路管理|管理 CNI、設定 overlay network|`Cilium`, `Weave Net`|
|🧪 節點健診|定時檢查 Node 健康狀況|`Node Problem Detector`|

### 避免 Node 被植入 DaemonSet 的方法

- 這個需求是因為，加入新的節點時，DaemonSet 慢慢地長出來的過程時，Pod 狀態肯定不會瞬間開好。 如果有一些監控告警機制，便有可能在這時候發出告警。 會嚇到人喔！
- 所以使用 `Taints + Tolerations` 機制，並改寫 **DaemonSet** 來避免直接被植入，是個好方法。
    
    > 之後再補充。
    

## Stateless 和 Stateful 的比較

### Stateless

- 前面提到，容器因為是 ephemeral 的關係，所以每次**生成容器**、**運行容器**直到 **關閉容器**；再次用相同的參數重啟後，還是回得到一模一樣的結果。 我們可以把它當成 **無狀態(Stateless)**。

### Stateful

- 如果要把容器拿來作為 **有狀態(Stateful)** 的應用，那需要克服容器中斷後資料揮發掉的情況。 他需要一個適當管理的永久儲存。
- 在 K8s 叢集，透過 **StatefulSet** 來管理，因為並不是把它當作「免洗筷」來使用，所以在命名上，理當依照使用目的，按照有序的方式將 Pod 取名，方便後續維運人員操作及管理。

### Pod 命名方式

|資源類型|Pod 命名規則|範例|是否包含隨機字串|
|---|---|---|---|
|`Deployment` / `ReplicaSet`|`<deployment-name>-<replicaset-hash>-<pod-id>`|`nginx-7d8b9c6f8b-4m2xl`|✅ 是（hash + 隨機）|
|`StatefulSet`|`<statefulset-name>-<ordinal>`|`mysql-0`, `mysql-1`|❌ 否（固定、有序）|
|`Job`|`<job-name>-<random-suffix>`|`batch-job-5z2kp`|✅ 是（為避免重複）|
|`CronJob`|`<cronjob-name>-<timestamp>`|`backup-1689253040`|✅ 是（根據時間戳）|
|`DaemonSet`|`<daemonset-name>-<pod-template-hash>-<random>`|`log-agent-fd89s`|✅ 是（帶 hash）|
|`Pod`（手動建立）|自己定義|`my-pod`|❌ 否（自己命名）|

### PVC / PV

- **PVC** 是 `PersistentVolumeClaim` 的縮寫，用來向叢集申請儲存空間的資源，具有「請求者（Claim）」的概念，它代表 Pod 向儲存系統提出的「我要空間」的需求。
- **PV** 則是 `PersistentVolume`，由叢集管理的永久儲存。

```yaml=
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 10Gi
```

### 存取模式

|模式|說明|
|---|---|
|`ReadWriteOnce` (RWO)|**單一 Node 可讀寫**，常見於 AWS EBS 等|
|`ReadOnlyMany` (ROX)|多個 Node 可**唯讀**|
|`ReadWriteMany` (RWX)|多個 Node 可**同時讀寫**，如 NFS、CephFS|

### PVC 的生命週期管理

1. PVC 先建立 → Kubernetes 尋找符合的 PV（或用 StorageClass 建）
2. 綁定後，Pod 可以使用 volumeMounts 掛載
3. 刪除 Pod 不會刪 PVC
4. 如果 StorageClass 有 reclaimPolicy: Delete，刪 PVC 也會刪 PV

### 小結 PVC 的特色

|類別|特點|
|---|---|
|抽象性|與儲存設備解耦，Pod 只認 PVC|
|安全性|資料與應用分離，不因重建 Pod 而遺失|
|可配置性|支援多種儲存後端與自動配置|
|彈性擴展|可搭配 StatefulSet、自動擴容（某些 CSI 支援）|
|適用場景|DB、ElasticSearch、持久型快取、備份空間等|

### StatefulSet 的特色

- 每個 Pod 有穩定的名稱與儲存（例如 db-0, db-1）
- 每個 Pod 有獨立 PVC
- Pod 的啟動與停止順序（有序）
- 但是它 **不會處理資料同步、複寫、選主（leader election）、failover。** 這些都必須由你部署的資料庫來負責。

## 結論

先確認情境，選擇合適的做法吧！

|情境|建議資源|
|---|---|
|每台 Node 都要跑一個守護程式（Log、Agent）|DaemonSet|
|系統級背景任務或 CNI 插件|DaemonSet|
|每個 Pod 都有獨立儲存與固定身份|StatefulSet|
|想確保有序升級 / 移轉 / 故障恢復|StatefulSet|
## Istio

- [**Istio**](https://istio.io/) 是一個 開源 Service Mesh 平台。
    - 連結： [https://istio.io/](https://istio.io/)
- 核心概念是透過 **sidecar proxy（通常是 Envoy） 攔截 Pod 的進出流量**，並將流量控制、憑證驗證、加密、監控等功能下放給 Mesh 層來處理，而不是讓應用程式自己處理。

### 主要功能

1. 流量管理 (Traffic Management)
    
    - 輕鬆實現藍綠部署、金絲雀發布、A/B 測試。
    - 支援流量分流、重試、熔斷、故障注入。
    
    > 就是分流
    
2. 安全性 (Security)
    
    - 預設支援 mTLS（雙向 TLS），保護服務之間通訊。
    - 透過 Policy 控制服務之間的存取權限。
    
    > mutual TLS  
    > 是零信任架構的一種，因為叢集內，可以透過 Cluster IP 去訪問別的容器。  
    > 透過 mutual TLS 避免被別叛徒偷聽。
    
3. 可觀測性 (Observability)
    - 自動收集遙測資料，包含流量統計、延遲、失敗率。
    - 整合 Prometheus、Grafana、Jaeger、Kiali 等工具，提供全鏈路追蹤與拓撲視覺化。
4. 平台整合性
    - 不只支援 Kubernetes，也可以延伸到 VM 或多雲環境。

在 OpenShift 裡，Red Hat 基於 Istio 提供了一個更容易安裝與維運的版本，稱為 **OpenShift Service Mesh (OSSM)**。

## 離線安裝

在有連上網際網路的 OCP 環境中，要安裝這些玩意兒，就是進到 OCP console 找到 **OperatorHub** 按一按就裝好了。 而大多情況，使用 OCP 的企業，很多都把叢集藏在內部網路，嚴加控管。 接下來會說明，無網路安裝的方法。

符合離線安裝的要素：

- 無法直接從 registry.redhat.io 下載 Operator 與相關映像。
- OCP OperatorHub 無法連線到 Red Hat 官方 Catalog。
- 需要部署 **QUAY** 或其他種 **Private Registry**。

### 準備映像

- 從有外網的環境，使用 `oc adm catalog mirror` 將 Red Hat Operator Catalog（包含 Service Mesh、Jaeger、Elasticsearch）鏡像到內部 Quay (quay.xxx.com)。

### 建立 CatalogSource：

- 在 disconnected OCP 裡建立一個 **CatalogSource**，指向內部 Quay registry 的 Operator Catalog。

### 安裝並配置 Istio (SMCP + SMMR)：

- 使用 **ServiceMeshControlPlane (SMCP)** 部署 Istio 控制平面。
- 使用 **ServiceMeshMemberRoll (SMMR)** 將應用 namespace 加入 mesh。

延續前一回的安裝話題，在 **Disconnected OCP - 離線 OCP 叢集**中，安裝與更新套件，是一個經典的場景。 由於無法直接從 `registry.redhat.io` 或 `quay.io` 抓取 Operator 或映像，必須要搭建私有 Quay registry 來解決離島的補給問題。

## 工具介紹

### Quay

1. 可以解決離線環境的映像 **來源問題**
    - **OCP 安裝** 與 **OperatorHub** 都依賴外部 registry
    - Disconnected 叢集需要替代方案。
2. 建立企業 **內部映像倉庫**
    
    - Quay 提供企業級的 registry，支援**權限控管、Robot Account、鏡像管理**。
    
    > 類似 Harbor [https://goharbor.io/](https://goharbor.io/)  
    > 還是 ECR 這種 [https://aws.amazon.com/tw/ecr/](https://aws.amazon.com/tw/ecr/)  
    > 但是咧，業主就是有錢，買買買！通通擺進來不要那麼囉唆。  
    > 管理不費心，還不用什麼雲地網路串接，通通離線讓稽核人員不要找麻煩。
    

### oc mirror

- 指令 `oc adm catalog mirror` 可以把 Red Hat Operator Catalog（或自訂 Operator）整包抓下來，再推送到私有 Quay。
    
    > 網管人員先在自己的聯網設備上，把東西拉下來，再拖進機房裡面，擺到倉庫。
    

## 詳細做法

### pull secret

- 需要準備 **Red Hat OpenShift 的 pull secret**，前往 Red Hat OpenShift Cluster Manager 下載 pull-secret.json。
    - 連結： [https://console.redhat.com/openshift/install/pull-secret](https://console.redhat.com/openshift/install/pull-secret)

```shell=
jq -c '.auths += {"quay.xxx.com": {"auth":"<base64-username:password>"}}' pull-secret.json > merged-pull-secret.json

```

### catalog 同步

```shell=
oc adm catalog mirror \
  registry.redhat.io/redhat/redhat-operator-index:v4.14 \
  quay.xxx.com/olm/redhat-operator-index:v4.14 \
  --registry-config=merged-pull-secret.json
```

### 建立 CatalogSource

```yaml=
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators-disconnected
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: quay.xxx.com/olm/redhat-operator-index:v4.14
  displayName: "Red Hat Operators (Disconnected)"
  publisher: quay.xxx.com
```

### 安裝 Operator

```yaml=
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  name: servicemeshoperator
  source: redhat-operators-disconnected
  sourceNamespace: openshift-marketplace

```

## 結論

- 建議先測試單一映像 push/pull，確認 Quay registry 認證沒問題，再進行大規模 oc mirror。
- `oc adm catalog mirror` 會抓下整個 Catalog，體積可能非常大，若只需要特定 Operator，可以改用 `oc mirror plugin` 搭配 imageSetConfig 精準選取。
- Robot Account 很好用，可以給 CI/CD 或自動化腳本專用。
- 若遇到 unauthorized 錯誤，多半是 Quay repo 沒建好，或帳號缺少 Write 權限。

SRE，全名是 Site Reliability Engineering，最早由 Google 提出，目的是 用軟體工程的方法解決系統運維問題。 SRE 最大的特色，就是將 DevOps 精神具體化、系統化，透過工程技術提高服務可靠性，同時保留創新速度。 在 SRE 領域中，監控（Monitoring） 與 可觀測性（Observability） 是確保系統穩定運行的關鍵核心。

## 可觀測性的三大支柱（Three Pillars of Observability）

> - 延伸閱讀： [Distributed Systems Observability  
>     by Cindy Sridharan](https://www.oreilly.com/library/view/distributed-systems-observability/9781492033431/ch04.html)
> - 連結：https://www.oreilly.com/library/view/distributed-systems-observability/9781492033431/ch04.html

|支柱|定義|實例|常用工具|
|---|---|---|---|
|**Metrics**|數值型資料，系統/服務健康狀態的 KPI|CPU 使用率、QPS、錯誤率|Prometheus, InfluxDB|
|**Logs**|時間序列的事件訊息，用來還原現場|應用錯誤日誌、Nginx 訪問紀錄|ELK Stack, Loki|
|**Tracing**|分散式系統的請求追蹤，知道請求去哪了|A → B → C 的延遲、瓶頸點|Jaeger, Zipkin, Tempo|

## SRE 關鍵觀念 / 名詞

- 常見的名詞縮寫，還有代表的意思，一定要記起來，才聽得懂別人在說什麼術語。

|名稱|說明|
|---|---|
|**SLI（Service Level Indicator）**|可以量測的服務指標（如延遲 < 500ms）|
|**SLO（Service Level Objective）**|希望達到的目標（如 99.9% 成功率）|
|**SLA（Service Level Agreement）**|與客戶簽約的服務水準（有法律效力）|
|**Error Budget**|容許的錯誤餘額（SLO - 實際表現）|

### 可觀測性：OCP 內建監控完整

- 使用 Prometheus Operator 收集指標
- 透過 Grafana Dashboards 可視化
- 整合 Elasticsearch + Kibana + Fluentd (EFK) 做日誌管理
- 使用 Jaeger/Tempo 追蹤 Service Mesh 請求路徑

### SLO 管理：以服務為中心

- 在 OCP 上部署服務時，可定義 Probe 來標記服務健康
- 使用 Prometheus 計算 Error Rate
- 用 Alertmanager 設定 SLO 達不到時通知

### Incident Response：OCP + GitOps 實現快速恢復

- 使用 ArgoCD / GitOps 管理配置
- 當設定異動時出現故障，Git revert 一鍵 Rollback
- 透過 `oc describe`, `oc logs`, `oc adm` 等指令快速調查原因

## 指令

1. 查看節點用量
    
    ```shell=
    oc adm top nodes
    
    NAME                        CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
    infra-1.xxxx.zzzzzzz.tw     1357m        38%    11288Mi         75%
    ```
    
2. 查看 Pods 資源用量
    
    ```shell=
    oc adm top pods -n <namespace>
    
    NAME          CPU(cores)   MEMORY(bytes)
    aaa-xxx       10m          80Mi
    bbb-zzz       15m          3684Mi
    ```
    
3. 查看所有指標
    
    ```shell=
    oc get --raw /api/v1/nodes/<node-name>/proxy/metrics
    ```
    
4. 透過 Prometheus 儀表板查看
    
    ```shell=
    oc get route -n openshift-monitoring
    ```
    

## SRE <--> OCP 元件

|🔑 **SRE 核心知識點**|💡 **概念說明**|🔧 **常見對應工具/服務**|📦 **在 OCP 的對應元件/方法**|
|---|---|---|---|
|**Metrics 指標監控**|可量測的數據，如 QPS、延遲、錯誤率|Prometheus、InfluxDB|`openshift-monitoring` 的 Prometheus|
|**Logging 日誌收集**|結構化紀錄系統事件，便於查錯|EFK (Elasticsearch + Fluentd + Kibana)、Loki|OpenShift Logging stack (`openshift-logging` Project)|
|**Tracing 追蹤請求流程**|跨服務追蹤，找出瓶頸和延遲來源|Jaeger、Zipkin、Tempo、OpenTelemetry|OpenShift Distributed Tracing (`jaeger-all-in-one`)|
|**Alerting 警示系統**|根據指標與規則發送通知|Prometheus Alertmanager、PagerDuty、Opsgenie|`Alertmanager` 內建於 `openshift-monitoring`|
|**SLO / SLI / SLA**|設定並監控服務水準目標|SLO 計算器、Grafana SLO panels|可用 PromQL 查詢、Grafana 呈現、結合 Alerts|
|**Error Budget**|容錯空間（1 - SLO）範圍內允許的錯誤|結合 SLI 計算公式，Grafana 顯示|使用 Prometheus rule 設定 + SLA dashboard|
|**Runbook / Playbook**|事先規劃好的故障排查 SOP|Confluence、Notion、Git repo 文字檔|儲存在 GitOps Repo / configmap / ConsoleLink|
|**Incident Management**|異常處理流程，包含通知、處置、回報|PagerDuty、Statuspage、Jira Incident|可整合 webhook 通知工具，或接收告警|
|**Postmortem 報告**|RCA 根因分析與後續行動方案|Google Docs、Markdown 模板、Incident.io|作為 CI/CD 的一部分或納入 GitOps flow|
|**Capacity Planning 容量預估**|根據歷史數據預測資源使用|Prometheus + Grafana + Forecast plugin|OpenShift Console 中資源圖表，或自建儀表板|
|**自動化修復**|系統異常時自動 rollback 或重啟服務|K8s Liveness/Readiness Probe、Argo Rollouts|OCP 中 Deployment 自動重啟、ArgoCD auto sync|
|**可用性設計**|多副本、容錯、冗餘、Failover|K8s HPA, Multi-zone Deploy, LoadBalancer|OCP 的 Route + HAProxy + HPA + readinessProbe|
|**Blackbox Monitoring**|從用戶端模擬請求驗證服務是否可用|Blackbox Exporter、curl script|安裝 blackbox-exporter 並用 ServiceMonitor 掛上|
|**Change Management**|控制部署頻率、管理風險|GitOps、Canary、Blue/Green Deploy|OpenShift GitOps (ArgoCD)、Route shifting|
|**Chaos Engineering**|故障演練、驗證系統韌性|Chaos Mesh、Gremlin、LitmusChaos|可於 dev 環境實作，或整合 K8s Job 模擬故障|
前面提到，要使用容器作為服務的基礎設施，必須考慮資料儲存的形式。 常見的就是寫資料庫，或是存在 **永久儲存**中 (永久的相對是揮發性儲存，像是記憶體或是容器本身)。 而 PV (PersistentVolume) 和 PVC (PersistentVolumeClaim) 常常一起出現，以下將對比兩者間的差異，以及如何使用。

## 1. 在 Worker Node 掛載儲存資源

從安裝硬碟在 Worker Node 之後，還有些設定要進行，才能使用

1. 查看叢集中節點 `oc get no`
2. 連到該節點上 `oc debug node/某worker-node名稱`
    - 這會啟用一個臨時的 Pod 來當作偵錯環境使用
    - 提示文字會告訴你如果要使用宿主主機上的命令，要用 `chroot /host`
3. 在該節點上 `chroot /host` 後， `lsblk` 確認新掛載的儲存設備有出現

## 2. 將實體儲存資源抽象化 / 建立 PV

就是在叢集中，建立 PV。 讓叢集取用。

### 建立 PV 設定

- 指定容量 (capacity)：可用的大小，例如 10Gi
- 存取模式 (accessModes)：
    - ReadWriteOnce (RWO) → 單 Node 可讀寫
    - ReadOnlyMany (ROX) → 多 Node 可讀
    - ReadWriteMany (RWX) → 多 Node 可讀寫
- 儲存來源 (storage backend)：
    - 本地目錄 (Local Path)
    - NFS
    - iSCSI
    - Ceph RBD / CephFS
    - 雲端磁碟（AWS EBS、GCP PD、Azure Disk）
- 回收策略 (reclaimPolicy)：PVC 釋放後 PV 的命運
    - Retain → 保留資料，管理員手動處理
    - Recycle → 清空再利用（K8s 新版不建議）
    - Delete → 直接刪除底層磁碟（常用於雲端動態配置）

### 建立 NFS PV 的範例

```yaml=
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /exports/data
    server: 192.168.1.100
```

### 建立 本地磁碟 PV 的範例

```yaml=
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  persistentVolumeReclaimPolicy: Retain
  local:
    path: /mnt/data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - worker-1
```

## 3. 使用者向叢集取用儲存資源 / 建立 PVC

- 開發者撰寫下列配置，或者利用 OCP console 在網頁介面上按按按。

### 建立 PVC

```yaml=
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
  namespace: myproject
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: local-storage

```

### Deployment / Pod 掛載 PVC

- 需要再 spec.volumes 中加入 pvc ，如下面範例：

```yaml=
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pvc
  namespace: demo
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
    volumeMounts:
    - mountPath: /usr/share/nginx/html   # 容器內目錄
      name: nginx-storage
  volumes:
  - name: nginx-storage
    persistentVolumeClaim:
      claimName: mypvc   # 指向剛建立的 PVC

```

- 最後要驗證的話，可以用 `oc rsh -n <所在命名空間> <pod名稱>` 連入 Pod 後，用 `df -h` 查看儲存。

## 比較表

- **PersistentVolume** 字面上意思就是 **「永久儲存」**，以下簡稱 **PV**。
- - **PersistentVolumeClaim** 字面上意思就是 **「永久儲存的宣告」**，以下簡稱 **PVC**。
- 兩者主要被設計出來的差異，在於 PV 通常都是叢集管理者建立出來，可以在整座叢集中流通； PVC 則通常由開發者向叢集要儲存資源，並且只能在相同 namespace 中流通。

|項目|PV (PersistentVolume)|PVC (PersistentVolumeClaim)|
|---|---|---|
|**角色**|叢集管理員提供的儲存資源|使用者向叢集申請的儲存需求|
|**建立者**|系統管理員手動建立，或由 StorageClass 動態建立|開發者 / 使用者在 Pod/Deployment 中宣告|
|**範疇**|Cluster-level（全叢集可用）|Namespace-level（限該命名空間使用）|
|**生命週期**|與實際儲存資源綁定（NFS、EBS、Ceph …）|與 Pod 相關，PVC 綁定後可重複使用|
|**容量**|PV 宣告可提供的大小（ex: 10Gi）|PVC 申請需要的大小（ex: 1Gi）|
|**存取模式**|定義存取方式（ReadWriteOnce, ReadOnlyMany, ReadWriteMany）|申請時需符合 PV 的模式|
|**綁定方式**|被 PVC 消費（Bound）後即被佔用|綁定到某個 PV 後才算可用|
|**刪除影響**|刪除 PV → 可能會釋放或保留底層資料（依 ReclaimPolicy）|刪除 PVC → 是否刪底層資料取決於 PV 的 ReclaimPolicy|
|**ReclaimPolicy**|Retain（保留資料）、Recycle（清空再利用）、Delete（直接刪除）|不直接控制，受 PV 的策略影響|

## 結論

- 針對各種形態的儲存設備，有各自的特性。 在速度，價格，容錯，聯網能力等，進行取捨。
- PVC 的三種存取模式，如下表呈現。
    - RWO 就是模擬成裝載機器上的儲存設備，允許單一寫入單一讀取。
    - ROX 是為了避免資料不同步，所以單一節點可寫入，但是多個節點可同時掛載讀取。
    - RWX 都是網路儲存，大家可以同時讀寫這個網路磁帶。

| AccessMode        | 縮寫  | 說明                 | 適用場景                                   |
| ----------------- | --- | ------------------ | -------------------------------------- |
| **ReadWriteOnce** | RWO | 允許單一 Node 掛載，且可讀寫  | 最常見，像 AWS EBS、Azure Disk、GCP PD 都是這種模式 |
| **ReadOnlyMany**  | ROX | 允許多個 Node 掛載，但只能讀取 | 多 Pod 共用資料但不需要寫入                       |
| **ReadWriteMany** | RWX | 允許多個 Node 同時掛載且可讀寫 | NFS、CephFS、GlusterFS、ODF CephFS        |
一座叢集中，會部署很多應用，然而在叢集內，彼此**預設是互通的**。 我們不能假設每個在使用叢集的程式、人都會乖乖地待在自己被允許的 **namespace** 中。 有些時候不安分的流量會掃描、試探 Cluster IP 去偷襲別人。 接著來理解 NetworkPolicy 核心觀念、常見範本、以及OCP 特有資源（EgressFirewall/EgressIP）。

![https://ithelp.ithome.com.tw/upload/images/20250909/2013014911w4kpXi7h.jpg](https://ithelp.ithome.com.tw/upload/images/20250909/2013014911w4kpXi7h.jpg)

## 簡介

- **容器網路介面（OVN-Kubernetes CNI）**，是預設「完全開放」，Pod 與 Pod 之間，沒有限制沒有阻擋。這對研發人員很爽，但隱含了極高的資安風險。
- NetworkPolicy 的本質就是「白名單」：只有被允許的流量可通過，其餘全擋。

### 重點觀念

1. 被 **podSelector** 選到的 Pod 才會被 NetworkPolicy 隔離；沒選到不管他。
    - 沒被列管的 Pod，就隨便他進出。
    - 有被選中列管的 Pod，只有被 **明確允許** 的連線會通過，沒提到的通通默認擋掉！
2. 在 **NetworkPolicy** 中，**Ingress/Egress** 是分管理的。
    - 不寫 ingress，就不會限制入口
    - 不寫 egress，就不會限制出口。
3. 規則是疊加的 Allow：多個 policy 可以一起放行更多路徑。
    
    - 沒有「顯性 Deny」(因為沒被允許的規則，就是禁止，所以不用特別禁他)。
    
    > 多個 Policy 疊加時：允許的規則會合併成 聯集（Union），也就是「誰放行，就能通過」。  
    > 但是 你不能寫一條規則來明確拒絕某來源，因為 NetworkPolicy 沒有 deny 語法。
    

### 建立原則

- podSelector：要列管的目標 Pod 群
- ingress / egress：描述誰可以進來、可以連去哪裡。
- from / to 常用條件：
    - podSelector：同 Namespace 內、帶某些 labels 的 Pod。
    - namespaceSelector：指定哪一些 Namespace（可搭配 labels）。
    - ipBlock：CIDR（支援 except 排除段）。
- ports：TCP/UDP/ SCTP 服務埠（建議明確列出）。

### podSelector 範例

- 假設 `api` **Pod** 被以下兩條 policy 選中：

1. **Policy A：** 允許 `web` **Pod** 連進來
    
    ```yaml=
    ingress:
      - from:
          - podSelector:
              matchLabels:
                app: web
    
    ```
    
2. **Policy B：** 允許 debug Pod 連進來
    
    ```yaml=
    ingress:
      - from:
          - podSelector:
              matchLabels:
                app: debug
    
    ```
    

- 效果：
    - `web` 可以連
    - `debug` 可以連
    - `db`（資料庫 Pod）不能連，因為沒被任何 policy 放行
    - 不能寫一條「顯性禁止 db」的 policy，因為語法不支援

## 範例

以下範例，假設存在某前端、後端的 Pod 在某 namespace 中，各自都帶上 label 了。 根據下列範本建立 Lab 吧。

### Build Lab

```shell=
# 建兩個專案（Namespace）
oc new-project team-a
oc new-project team-b

# 在 team-a 部署兩個角色：api 與 web
oc -n team-a create deploy api --image=ghcr.io/jmalloc/echo-server:latest --port=8080
oc -n team-a expose deploy/api --port=8080 --target-port=8080
oc -n team-a label deploy api app=api tier=backend --overwrite=true

oc -n team-a create deploy web --image=nginx:alpine
oc -n team-a label deploy web app=web tier=frontend --overwrite=true

# 在 team-b 放一個 busybox 當「外人」
oc -n team-b run dbg --image=busybox:1.36 --restart=Never --command -- sh -c 'sleep 1d'

```

### 連線測試

設定 NetworkPolicy 前，來測測看什麼叫做暢行無阻。

```shell=
# 先找出 team-a 內部服務的 ClusterIP 與 Port
oc -n team-a get svc api

# 從 team-a 的 web Pod 嘗試連 api
WEB_POD=$(oc -n team-a get po -l app=web -o jsonpath='{.items[0].metadata.name}')
oc -n team-a exec -ti $WEB_POD -- wget -qO- http://api:8080

# 從 team-b 的 dbg 嘗試連 team-a 的 api（預期成功，因為還沒隔離）
oc -n team-b exec -ti dbg -- wget -qO- http://api.team-a.svc.cluster.local:8080

```

## 設定 NetworkPolicy

### 步驟一：把後端的進出，全部擋起來！

- 我們在部署三層是架構的服務時，前端面對普羅大眾，後端因為要配合 API 承接前端的請求，增刪修查資料庫或是其他處理。 不希望無關人士進來搗亂。
    
    > - 前端，可以類比成餐館的用餐區，有外場服務生服務客人，客人可以依照菜單上提供的項目點餐，或者是當一個奧客搞破壞。
    > - 後端，可以類比成餐館的廚房，和內場廚師。 餐飲業稱這個叫做後場或是內場。
    > - 資料庫，可類比成食材庫房和倉庫。
    
- 所以，對 tier=backend 的 Pod 上 Ingress/Egress 全拒絕（選到才開始隔離）

```yaml=
# deny-all-backend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-backend
  namespace: team-a
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
    - Ingress
    - Egress

```

> 寫完 yaml 記得套用

### 步驟二：允許特定來源可以與後端溝通

- 後端有開放 8080 port 的話，下列設定允許同為 `team-a` namespace 的 Pod 訪問 8080 port

```yaml=
# allow-frontend-to-backend-8080.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend-8080
  namespace: team-a
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              tier: frontend
      ports:
        - protocol: TCP
          port: 8080

```

> 寫完 yaml 之後也要套用

### 驗證連線

```shell=
# 同 NS 前端打後端 -> 成功
oc -n team-a exec -ti $WEB_POD -- wget -qO- http://api:8080

# team-b 外部打後端 -> 失敗
oc -n team-b exec -ti dbg -- wget -qO- http://api.team-a.svc.cluster.local:8080 || echo "blocked"

```

## 常見的場景

### 允許同 Namespace 連線

- 允許同 Namespace 內全部 Pod 訪問我（但擋跨 Namespace）

```yaml=
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: team-a
spec:
  podSelector: {}  # 選到本 NS 所有 Pod → 都開始被隔離
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector: {}  # 同 NS 內任何 Pod

```

### 允許指定 Namespace 的哪個 Pod 連線

- 允許特定 Namespace（加了 label）的 Pod 訪問我

```yaml=
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-partner-ns
  namespace: team-a
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              access: partner
      ports:
        - protocol: TCP
          port: 8080

```

### 允出指定 IP / 禁止指定 IP

- **明確允許** 連出的 IP
- **明確排除** 連出的 IP

```yaml=
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-to-cidr
  namespace: team-a
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: [Egress]
  egress:
    - to:
        - ipBlock:
            cidr: 10.0.0.0/8
            except:
              - 10.10.0.0/16

```

### 指定允出協定

- 只放行特定 Port（HTTP/HTTPS），其他一律擋

```yaml=
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-80-443-only
  namespace: team-a
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes: [Ingress]
  ingress:
    - ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443

```

## OCP 特有： 「EgressFirewall」 與 「EgressIP」

- NetworkPolicy 的 egress.to 只能寫 CIDR，不能寫 FQDN。
- OCP 上使用 OVN-Kubernetes，有兩個方便的 OCP CRD 可以拿來用。

### EgressFirewall（Namespace 級別的對外規則，支援 FQDN）

- 在某個 Namespace 內，集中定義**「往外」的允許/拒絕**，且可用 `dnsName`。

```yaml=
apiVersion: k8s.ovn.org/v1
kind: EgressFirewall
metadata:
  name: default
  namespace: team-a
spec:
  egress:
    - type: Allow
      to:
        dnsName: api.github.com
    - type: Allow
      to:
        cidrSelector: 0.0.0.0/0
      ports:
        - protocol: TCP
          port: 443

```

> 備註一： EgressFirewall 設定的目標是 namespace，不是 pod  
> 備注二： 通常會先一條允許特定 FQDN，再用第二條收斂到 443，剩下由 DNS 名稱控管。

### EgressIP（固定對外來源 IP）

為了讓某些 Namespace 的對外連線，NAT 成指定的 Egress IP（給防火牆白名單或第三方 API 綁定）。 在 Namespace 打上 k8s.ovn.org/egress-ips annotation，並在叢集層配置可用 Egress IP 與負載承載節點（此段通常由叢集管理員配置）。

## 結論

- 關於管理的訣竅
    - 怎麼驗證 PodSelector 寫得對不對？
    - 用指令 `oc describe networkpolicy` 看 PodSelector 是否真的覆蓋到你的 Pod。
    - ![https://ithelp.ithome.com.tw/upload/images/20250909/20130149xaqiygmlhP.png](https://ithelp.ithome.com.tw/upload/images/20250909/20130149xaqiygmlhP.png)
- 「可以解析域名」，和「可以訪問域名」是兩回事。 多得是你知道主機在哪裡，但你到不了。
- 連 Service / 連 Pod 的差異
    
    - Network Policy 是檢查 Pod 之間的 Layer 3 和 Layer4 連線 (IP、Port、Protocol)，無關你是用什麼樣的 Service 名稱進行訪問。
    - 用 Service 名稱連線時，**DNS 先解析成 ClusterIP** → **iptables/OVN-Kubernetes 負載** 分流 → 最後實際**連到 Pod IP**。
    
    > NetworkPolicy 就是在上述的最後一段，判斷要不要放行。  
    > 解得出 Service Name 不代表有被允許連線喔！！