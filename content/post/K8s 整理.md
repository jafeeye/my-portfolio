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