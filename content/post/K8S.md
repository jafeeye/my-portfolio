---
title: K8s
toc: true
date: 2026-05-22
---
K8S 
有多種版本架設方式：kubeadm、K3s、Minikube
有對應多個runtime engine：containerd、crio、k3s_containerd

**[kubevirt-manager](https://github.com/kubevirt-manager/kubevirt-manager)**
Cert-manager  
Forecastle 實戰：以 annotation 自動發現的 Kubernetes 應用入口面板  
Harbor 建立私有helm倉庫及ArgoCD拉取設定  
KubeClipper (CNCF)  
9Router  
Dashboard  
Rancher  
ArgoCD  
[headlamp](https://github.com/kubernetes-sigs/headlamp)  


![](Diagram2.svg)

## 安裝Master,Worker1,Worker2
先修改3台hostname
```
# 0.初始化machineid
rm -f /etc/machine-id ;
rm -f /var/lib/dbus/machine-id ;
systemd-machine-id-setup ;

# 1. 關閉swap
sudo swapoff -a 
## 永久關閉：編輯 /etc/fstab，將有 swap 的那一行用 # 註解掉 
sudo sed -i '/swap/d' /etc/fstab

# 2. 調整 SELinux 與 防火牆
## 將 SELinux 調整為 Permissive (寬容模式)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
## 處理防火牆 (為了測試順利，先關閉 firewalld；生產環境則需逐一放行 Port)
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# 3. 啟用 Linux 核心網路模組與轉發
## 載入模組
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
## 設定核心參數
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
## 套用參數
sudo sysctl --system

# 4. 安裝 Containerd (Docker 官方源)
## 新增 Docker CE 軟體源
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

## 安裝 containerd
sudo dnf install -y containerd.io

## 產生並修正設定檔 (啟用 SystemdCgroup)
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

## 啟動並設定開機自啟
sudo systemctl daemon-reload
sudo systemctl restart containerd
sudo systemctl enable containerd

# 5. 安裝主要元件 kubeadm, kubelet, kubectl
## 新增 K8S YUM 軟體源 (以 v1.30 為例)
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF

## 安裝套件 (使用 --disableexcludes 允許安裝被排除在外的主程式)
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

## 啟動 kubelet 開機自啟 (此時它會不斷重啟是正常的，直到 kubeadm init 完成)
sudo systemctl enable --now kubelet

```

7. 初始化Master Node,注意後面網路元件會影響起始CIDR,因為這邊是用Cilium就用那條,此時會產生kubeadm join -- token 這個就是在網路元件安裝完在貼去另外兩台Worker
```
#Calico 預設的Pod CIDR 192.168.0.0/16
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.8.83

#Cilium 預設的Pod CIDR 10.244.0.0/16
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=172.16.7.199
```

8. Master Node 設定kubeconfig 權限,並加入其他2台Worker主機
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
一開始產生加入節點指令趕快記下來,有效期為24小時,如果真的忘了只好重新生成
K8S安裝完成，用下面檢查指令master主節點是否正常運行
```
kubectl get nodes
kubectl get nodes -w //持續監控是否正常運行
```
確認無誤後,將其他2台也加入節點
```
sudo kubeadm join 192.168.1.10:6443 --token <你的token> \
    --discovery-token-ca-cert-hash sha256:<你的hash值>
```

9. 安裝CNI網路元件,這邊示範用cilium
```
curl -L --remote-name https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz ;
sudo tar xzvf cilium-linux-amd64.tar.gz -C /usr/local/bin ;
cilium install ;
cilium status --wait
```
10. CNI 外掛網路層安裝完成
```
:'可以啟用webui'
cilium hubble enable --ui

:'打hubble ui,出現 "localhost:12000" in your browser.代表服務啟動'
cilium hubble ui

:'預設不給外部連線,要加上--address 0.0.0.0 允許所有連線'
kubectl port-forward -n kube-system svc/hubble-ui 12000:80 --address 0.0.0.0
```

重啟
```
kubectl rollout restart deployment hubble-ui -n kube-system
```


Calico 安裝方法
```
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
kubectl get pods -n kube-system -l k8s-app=calico-node
## 如果安裝成功,nodes會變成ready狀態
kubectl get nodes
```





## 額外套件

### Helm (K8s套件管理器)
```
: '安裝helm' 
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ;

: '加入 helm tab自動補字' 
helm completion bash > /etc/bash_completion.d/helm ;

: '刷新當前終端機環境' 
source /etc/bash_completion.d/helm ;
```

例：用helm安裝Nginx套件(OCI方式),並開好對外Port
```
# 安裝nginx
helm install my-nginx oci://registry-1.docker.io/bitnamicharts/nginx \ -n web-system \ --create-namespace \ --insecure-skip-tls-verify
# 查看services 知道對外Port,看到80:32760代表內:外為32760
kubectl get services -n web-system
# 去改type:,把他變成NodePort
kubectl edit svc my-nginx -n web-system
```


### Krew (kubectl外掛套件管理器)
```
: 'Kubectl Krew 外掛安裝確保系統有安裝 git 與 tar (Krew 下載套件必備)'
dnf install -y git tar ;

: '進入臨時目錄，下載並解壓 Krew 最新版本'
cd /tmp && \
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz" && \
tar -zxvf krew-linux_amd64.tar.gz ;

:'執行 Krew 原生安裝程序'
./krew-linux_amd64 install krew ;

:'將 Krew 寫入環境變數 (讓 kubectl 能隔空呼叫它)'
# 寫入 root 的 .bashrc 設定檔中
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc ;

# 立刻刷新當前 Shell 環境變數，免重新登入
source ~/.bashrc
```

插件：ktop
```
kubectl krew install ktop
kubectl ktop
```

### KubeVirt 安裝
```
#取得最新版號
export VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | grep tag_name | cut -d '"' -f 4)
export CDI_VERSION=$(curl -s https://api.github.com/repos/kubevirt/containerized-data-importer/releases/latest | grep tag_name | cut -d '"' -f 4)

#部署 KubeVirt 的 Operator 與 CRD 核心
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml"
kubectl create -f "https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-cr.yaml"

#取得kubevirt
kubectl get pods -n kubevirt
```
安裝KubeVirt-Manager
```
kubectl apply -f https://github.com/kubevirt-manager/kubevirt-manager/releases/download/v1.5.4/bundled-v1.5.4.yaml
kubectl get pods -n kubevirt-manager -o wide
```
編輯KubeVirt-Manager WebUI
```
[root@k8s1 ~]# kubectl get pods -n kubevirt-manager -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP         NODE   NOMINATED NODE   READINESS GATES
kubevirt-manager-66d9875ccf-djw5n   1/1     Running   0          48s   10.0.2.209   k8s3   <none>           <none>
```
編輯檔案,把`type:` 改成 `type: NodePort`
```
kubectl edit svc kubevirt-manager -n kubevirt-manager
```
驗證
```
kubectl get pods -n cdi
```

### Rancher 安裝
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
## 安裝cert-manager
helm install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --set installCRDs=true

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher   
  --namespace cattle-system   
  --set hostname=192.168.8.83  
  --set replicas=1   
  --set bootstrapPassword=admin

kubectl rollout status deployment/rancher -n cattle-system

## 進去去把type改成NodePort
kubectl edit svc rancher -n cattle-system

## 驗證
kubectl get svc -n cattle-system rancher
```

## 安裝illumio

注意事項
- 本機的 /etc/hosts 一定都要寫入pce的FQDN,不然會找不到
- CoreDNS 也要寫入對應pce的FQDN
- 憑證記得對應

2. 新增一個`illumio-values.yaml` 
```
# PCE URL&port, example.com:8443
pce_url: <URL_PORT> 
# Cluster ID from PCE, Cluster ID              
cluster_id: <ILO_CLUSTER_UUID>    
# Cluster Token from PCE
cluster_token: <ILO_CLUSTER_TOKEN>
# Pairing Profile key,container profile
cluster_code: <ILO_CODE>

# Container runtime,engine,values [containerd, crio, k3s_containerd]       
containerRuntime: containerd
# Container manager,values [kubernetes, openshift]  
containerManager: kubernetes       
# Allowed values [legacy", "migrateLegacyToClas", "clas", "migrateClasToLegacy]
clusterMode: clas                  

# using a private PKI , need to add these additional lines below
extraVolumeMounts:
  - name: root-ca
    mountPath: /etc/pki/tls/ilo_certs/
    readOnly: false
extraVolumes:
  - name: root-ca
    configMap:
      name: root-ca-config
```

2. 抓取憑證
SSL 憑證的世界裡，有分兩種憑證：
**Server 憑證（身分證）：** 證明「我是 PCE 伺服器」。
**CA 根憑證（內政部印章）：** 專門用來簽發各個 Server 憑證的源頭。


```
#方法1,http抓取法
openssl s_client -showcerts -connect pce.example.com:8443 </dev/null 2>/dev/null | openssl x509 -outform PEM > /tmp/illumio-pce-ca.crt
#方法2,scp匯入法
scp root@<PCE_IP>:/var/lib/illumio-pce/cert/server.crt /tmp/illumio_ca.pem

#上面方法擇1後,把憑證匯入k8s Master Node
kubectl create namespace illumio-system --dry-run=client -o yaml | kubectl apply -f - ;
kubectl -n illumio-system create configmap root-ca-config --from-file=/tmp/illumio_ca.pem
```

憑證改檔名

```
kubectl create configmap root-ca-config -n illumio-system \
--from-file=ilo_root_ca.crt=/tmp/illumio_ca.pem \
--from-file=server.crt=/tmp/illumio_ca.pem \
--dry-run=client -o yaml | kubectl apply -f -
```


連線需要解析hostname,K8s預設用CoreDNS,在設定檔更改,改 vi /etc/hosts沒用
```
kubectl edit cm coredns -n kube-system
```
修改檔案為以下,在Corefile後的ready段加入hosts {} 裡面解析
```
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        hosts {
            192.168.8.28 illumio-kevin.dev
            fallthrough
        }
```

helm安裝
```
helm install illumio -f illumio-values.yaml oci://quay.io/illumio/illumio --namespace illumio-system --create-namespace
```


檢查illumio 狀態
```
kubectl get pods -n illumio-system -w


## 進去k8s的bash檢查狀態，確認agent ven platform都在
kubectl exec -it illumio-ven-9z7nv -n illumio-system -- /bin/bash
ps -ef | grep -E "agent|ven|platform"

## 查illumio log
kubectl logs illumio-ven-fvd8p -n illumio-system --previous

kubectl scale deployment/illumio-kubelink --replicas=0 -n illumio-system
kubectl scale deployment/illumio-kubelink --replicas=1 -n illumio-system
curl -4 -v https://illumio-kevin.bd1.dev:8443

```

重啟pod
```
kubectl rollout restart deployment illumio-kubelink -n illumio-system
```


重新配對
```
kubectl delete ds --all -n illumio-system
kubectl delete deployment --all -n illumio-system
kubectl get pods -n illumio-system -w
systemctl stop illumio-ven 2>/dev/null
rm -rf /opt/illumio_ven_data/* 
rm -rf /var/log/illumio/*
helm uninstall illumio -n illumio-system
helm install illumio -f illumio-values.yaml oci://quay.io/illumio/illumio --namespace illumio-system --create-namespace
kubectl rollout restart ds -n illumio-system

```

Felix configuration 用於iptable


## ingress controller

**外部 Client** $\rightarrow$ **Ingress Controller Service** $\rightarrow$ **Ingress 路由規則** $\rightarrow$ **應用程式 Service** $\rightarrow$ **應用程式 Pod**

具體關聯如下：
1. **入口層（`my-nginx-controller.yaml`）**：
    - 它是一個 `type: LoadBalancer` 的 Service（在沒有雲端負載均衡器的地端環境，會退化成透過 `nodePort` 30184 和 32394 監聽）。
    - **關聯**：它的 `selector` 指向了 Nginx Ingress Controller 的 Pod，作為整個叢集接收 HTTP (80) / HTTPS (443) 流量的唯一總閘門。
2. **路由層（`my-ingress.yaml`）**：
    - 這是路由大腦。它定義了當有人從外部訪問 `myapp.example.com` 且路徑為 `/` 時，該把流量帶去哪裡。
    - **關聯**：
        - 透過 `ingressClassName: nginx` 告訴上述的 Nginx Ingress Controller 來認領並執行這條規則。
        - 透過 `backend.service.name: my-web-service` 連結到您的後端應用程式。
3. **應用層（`test-app.yaml`）**：
    - **`Service (my-web-service)`**：名稱剛好對應 Ingress 寫的後端名稱，它負責把來自 Ingress Controller 的流量，分發給後端的 Pod。
    - **`Deployment (my-web-deployment)`**：實際運行 `nginx:alpine` 網頁程式的 Pod（Label 為 `app: my-web-app`）。

my-nginx-controller.yaml
```







```





my-ingress.yaml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: default
  annotations:
    # 指定使用 nginx 作為 ingress controller
    kubernetes.io/ingress.class: "nginx"
    # 選填：開啟 SSL 強制重新導向
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com  # 你的網域
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-web-service # 後端服務名稱
            port:
              number: 80         # 後端服務連接埠
```












## 拉取映像
映像檔：https://artifacthub.io/packages/ 
現在主流是bitnami倉庫，但是現在被Broadcom收購，映像檔只能拉latest
```
helm repo add bitnami https://charts.bitnami.com/bitnami 
helm repo update
```

```
helm search hub wordpres
helm install my-wordpress bitnami/wordpress
helm install bitnami/wordpress --generate-name
helm list
```



## 常用指令
```
## 建立pod
kubectl create -f kubernetes-demo.yaml 

## 查看pod
kubectl get pods

## 做port-forward,把本機的port跟對外mapping 可以連線
kubectl port-forward kubernetes-demo-pod 3000:3000

## kustomize
kustomize build k8s | kubectl apply -f -
```

清空Master Node Cluster
```
sudo kubeadm reset -f ;
sudo rm -rf /var/lib/etcd ;
sudo rm -rf /etc/cni/net.d ;
```
無法加入節點,因為三台時間不一致

其他兩台Worker節點清除
```
kubeadm reset -f
rm -rf /etc/kubernetes/pki/
```
無法連線,要把Cluster IP 改成NodePort


## 錯誤訊息
- 出現 `kubectl` 都跳出類似 `connection refused` 訊息,是`kubeadm` 預設會把設定檔放在 `/etc/kubernetes/admin.conf`,要把記得設定檔複製到 root 的家目錄
- 出現 error execution phase kubelet-start: a Node with name "localhost.localdomain" and status "Ready" already exists,代表hostname撞名了,發生於大量模板,要改hostname
- 出現 `/etc/kubernetes/pki/ca.crt already exist` 原因是kubeadm join雖然hostname重複失敗,但K8s還是在背景產出 ca.crt, 這時候下清除指令 `kubeadm reset -f`
- K8S 預設是不允許一般 Pod（如 Hubble-Relay）調度到 Master 上的,所以沒有其他Worker 節點跑pod也是
- **CNI 設定（如 Calico, Flannel 等）：** 它提示說沒有刪除 `/etc/cni/net.d`。如果你這台機器之前**從來沒有成功 join 變成 Ready 狀態過**，那這裡面通常是空的，不用管它；但如果這台機器很久以前當過其他的 K8s 節點，建議順手把它刪了：`rm -rf /etc/cni/net.d/*`。
- **Kubeconfig 殘留：** 它提醒你檢查 `$HOME/.kube/config`。因為你現在是要 join 進去，待會成功後我們會重新複製新的進去，所以現在可以先把舊的砍掉，避免混淆：
- 如果要加入節點無法加入要除錯,join指令最後打上 `--v=5`
```
rm -rf $HOME/.kube/
```



