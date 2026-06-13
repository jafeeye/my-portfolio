---
title: k8s整理
toc: true
date: 2026-05-30
---
| Feature/發行版                  | Kubernetes | **MicroK8s**         | **k0s**              | **k3s**                  | **KubeSolo**       |
| ---------------------------- | ---------- | -------------------- | -------------------- | ------------------------ | ------------------ |
| shell                        | Kubeadm    |                      |                      |                          |                    |
| Architecture                 |            | Multi-node capable   | Multi-node capable   | Multi-node capable       | Single-node only   |
| Resource Usage               |            | 600MB+ RAM           | around 300–400MB RAM | around 500MB+ RAM        | **==<200MB RAM==** |
| etcd                         |            | Embedded Dqlite/etcd | Embedded etcd        | Optionally embedded etcd | No etcd            |
| Cluster Support              |            | Yes                  | Yes                  | Yes                      | No                 |
| Helm/CRD Support             |            | Yes                  | Yes                  | Yes                      | Yes                |
| Designed for Edge            |            | Yes                  | Yes                  | Yes                      | Yes                |
| System Requirements          |            | Moderate             | Moderate             | Moderate                 | Ultra-low          |
| Read-only Filesystem Support |            | No                   | Partial              | Partial                  | Yes                |
Talos Omni On-Prem

minikube：一個打包安裝工具，直接裝好魔改linux跟K8S

Kind 或 kubeadm差別是


## 範例建立nginx pod

建一個pod，寫一個yaml `nano test-nginx.yaml` ，存檔後`kubectl apply -f test-nginx.yaml`
```
apiVersion: v1
kind: Pod
metadata:
  name: test-web
  namespace: default
  labels:
    app: test          # 用於與 Service 聯動的標籤
    role: front-end    # 讓 Kubelink 抓取並對應到 Illumio 身份標籤
  annotations:
    # Calico 指派192.168.1.5給這個測試 Pod
    cni.projectcalico.org/ipAddrs: "[\"192.168.1.5\"]"
    # cilium 改成下面這個
    cni.cilium.io/ipAddress: "10.244.1.5" # 故意指定同一個 IP
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
---
# 用三個減號隔開，下面直接接 NodePort Service 的設定
apiVersion: v1
kind: Service
metadata:
  name: test-service
  namespace: default
spec:
  type: NodePort
  selector:
    app: test          # 精準對齊上面 Pod 的 labels.app
  ports:
  - port: 80           # Service 內部監聽的連接埠
    targetPort: 80     # 轉發給 Pod 的連接埠
    nodePort: 31002    # 強制指定對外實體節點的連接埠為 31002
```

查pod 狀態:`kubectl get pods -A`
![](Pasted%20image%2020260602171514.png)
查log：`kubectl describe pod test-web -n default`

看pod ip 分配設定
```
# 1. 查詢你的 K8s 目前實際有效的 Calico IP 池範圍 
kubectl get ippools.crd.projectcalico.org -o wide 
# 或者是（取決於你裝的 Calico 版本工具）： 
kubectl get ippool -o yaml
```

看Pod ip： `kubectl get pods -o wide -A`
![](Pasted%20image%2020260603092433.png)

更新pod
```
# 原本拉好套用yaml 
kubectl apply -f test-nginx.yaml

# 強制刪除舊的 Pod 與 Service，避免搶奪 IP 號碼牌
kubectl delete pod test-web -n default --force --grace-period=0
kubectl delete svc test-service -n default --ignore-not-found
# 在套用一次yaml
kubectl apply -f test-nginx.yaml
```


修改calico 資源pool的ip
```
kubectl edit ippools
## 把cidr 改成 cidr: 10.244.0.0/16

# 1. 重啟所有命名空間下的 Deployment (包含 coredns, Kubelink, apps 等)
kubectl get deployments -A -o jsonpath='{range .items[*]}{.metadata.name}{" -n "}{.metadata.namespace}{"\n"}{end}' | xargs -I {} sh -c 'kubectl rollout restart deployment {}'

# 2. 重啟所有命名空間下的 StatefulSet (如果有資料庫或 stateful 服務)
kubectl get statefulsets -A -o jsonpath='{range .items[*]}{.metadata.name}{" -n "}{.metadata.namespace}{"\n"}{end}' | xargs -I {} sh -c 'kubectl rollout restart statefulset {}'


```

修改Cilium
```
## Cilium預設是用ClusterPool
kubectl edit cm cilium-config -n kube-system
## 把cluster-pool-ipv4-cidr 改成10.244.0.0/16
kubectl rollout restart deployment cilium-operator -n kube-system kubectl rollout restart daemonset cilium -n kube-system

```


System Pods 系統組件

|**元件名稱 (System Pod)**|**預設角色與架構定位**|
|---|---|
|**`kube-apiserver`**|K8s 的唯一入口。所有指令（包含你的 `kubectl`、Illumio 的 Kubelink）都要跟它通訊。|
|**`etcd`**|K8s 的資料庫。存放整個叢集所有的狀態與密碼（預設是明文未加密的 key-value 儲存）。|
|**`kube-scheduler`**|負責看哪台 Worker 節點還有空位，把新 Pod 塞過去。|
|**`kube-controller-manager`**|負責維持叢集狀態（例如發現 Pod 死掉，立刻在別處拉起一隻新的）。|
|**`coredns`**|叢集內部的 DNS 伺服器。負責幫 Pod 解析服務名稱（例如 `my-db.default.svc.cluster.local`）。|
|**`kube-proxy`**|負責維護每台 Node 上的 iptables 規則。當流量要找某個 K8s Service 時，由它負責把流量均分導向後端的 Pod。|

Default Namespace
```
kubectl delete --all deployment 
kubectl delete --all service 
kubectl delete --all serviceaccount 
kubectl delete --all virtualservice 
kubectl delete --all gateway 
kubectl delete --all destinationrule
```


## 架構
![](Pasted%20image%2020260610102631.png)

### Service Mesh 架構 (MicroServices)
Cilium+Isito
- **Cilium 做底層網路（Layer 3/4）：** Cilium 利用 Linux 核心的 **eBPF 技術**，讓 Pod 與 Pod 之間的 IP 互連速度達到極致（因為它強行跳過了傳統 Linux 複雜的 iptables 協議棧）。它負責管好基本連線，以及基於 IP/Port 的簡單防火牆規則。
- **Istio 做上層治理（Layer 7）：** 當流量需要做進階處理（例如：HTTP 路由、金絲雀部署、檢查 API 路徑、雙向 mTLS 加密）時，Cilium 就把流量交給 Istio 塞在 Pod 裡面的 **Sidecar Proxy (Envoy)** 去處理。

### Containerized Monolith 架構

istio 現在新版有ztunnel 做 L4（Ambient），在 Pod 之間跑 **mTLS 強制加密**
![](Pasted%20image%2020260610172202.png)

## DS nginx
nano test1-nginx.yaml
```
apiVersion: apps/v1        #【修正】DaemonSet 的標準 apiVersion 是 apps/v1
kind: DaemonSet            #【修改】從 Deployment 改為 DaemonSet
metadata:
  name: test1-web
  namespace: default
  labels:
    app: test              # 用於管理這個 DaemonSet 物件本體的標籤
spec:
  selector:
    matchLabels:
      app: test            # 精準咬住下方 template.metadata.labels 中的 app 標籤
  template:
    metadata:
      labels:
        app: test          # 用於與下面的 Service 聯動
        role: front-end    # 讓 Kubelink 抓取並對應到 Illumio 身份標籤
      annotations:
        # Cilium 指派靜態 IP 設定（如需啟用可將前方的 # 號拿掉）
        # cni.cilium.io/ipam-static-ip: "10.244.1.5"
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
# 下面保持原本的 NodePort Service 設定，確保完美咬住 DaemonSet 產生的每一個 Pod
apiVersion: v1
kind: Service
metadata:
  name: test1-service
  namespace: default
spec:
  type: NodePort
  selector:
    app: test          # 精準對齊上面 Pod 模板中的 labels.app
  ports:
  - port: 80           # Service 內部監聽的連接埠
    targetPort: 80     # 轉發給 Pod 的連接埠
    nodePort: 31002    # 強制指定對外實體節點的連接埠為 31002
```

移除服務 `kubectl delete -f test1-nginx.yaml`
編輯服務 ` kubectl edit ds test1-web -n default`

查看特定pod `kubectl get po test-web -o wide`