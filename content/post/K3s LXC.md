---
title: K3s LXC
toc: true
date: 2026-07-10
---
## 什么是 K3s？
![](static/2023_06_26_22_41_07_72d1e9e6f582.jpg)

K3s 是一个专为资源受限环境设计的轻量级 Kubernetes 发行版，具备完整的 Kubernetes 兼容性，同时去除了一些不必要的组件，部署更快、使用更简单。
适用于边缘计算、IoT 设备、小型生产环境和开发测试等场景。

K3s 的核心优势：
- **轻量简洁**：二进制体积小，依赖少
- **部署快速**：一条命令即可启动 Kubernetes
- **资源占用低**：最低可运行在 512MB 内存设备上

为什么选择 LXC 容器？
- **更高效**：相比完整虚拟机，占用资源更少
- **更隔离**：提供安全、独立的运行环境
- **更灵活**：在 Proxmox 中便于扩容和管理
通过使用 LXC 容器运行 K3s，可以在不牺牲性能的前提下实现更高的资源利用率。

为什么要将 K3s 与 Proxmox 容器结合？
将 K3s 部署在 Proxmox 容器中，可以充分发挥两者的轻量与高效特性。这一组合非常适合：
- 对 Kubernetes 感兴趣的 Homelab 爱好者
- 资源有限的边缘计算场景
- 预算有限的中小型企业

![](static/Kubernetes-k8s-安裝選擇地圖-1.png)

## 在 Proxmox 容器中安装 K3s

目前發現問題，重開機export KUBECONFIG=/etc/rancher/k3s/k3s.yaml 這個設定會不見，原因不明

Step 1：创建 LXC 容器
在 Proxmox 用户界面中，单击 “创建 CT”。填写 LXC 容器的详细信息。确保取消选中“无特权的容器”复选框：  (不要在建立好unprivileged=1改回0，權限會大亂)
![](https://raw.githubusercontent.com/kingsd041/picture/main/202507102112500.png)
选择模板，本例使用 Ubuntu 20.04：  
![](https://raw.githubusercontent.com/kingsd041/picture/main/202507102113959.png)
磁盘、CPU、内存，网络根据实际情况设置，并在最后一页，确认你的设置，然后单击“完成”。Proxmox 将创建容器：  
![](https://raw.githubusercontent.com/kingsd041/picture/main/202507102122457.png)

Step 2：修改 pve 主机配置
现在，我们需要进行一些底层调整，赋予容器适当的权限。你需要通过 root 用户 ​ SSH 连接到 Proxmox 主机，在/etc/pve/lxc 目录中，你将找到名为 XXX.conf 的文件，其中 XXX 是我们刚刚创建的容器的 ID 号。修改该文件并添加以下几行：
```
lxc.apparmor.profile: unconfined 
lxc.cgroup.devices.allow: a 
lxc.cap.drop: 
lxc.mount.auto: "proc:rw sys:rw"
```

按顺序，这些选项的含义:
1. 禁用 AppArmor
2. 允许容器的 cgroup 访问所有设备
3. 防止丢弃容器的任何功能
4. 在容器中/proc 以/sys 读写方式挂载。

**Step 3：启动 LXC 容器，并修改容器配置**
LXC 容器中需要确保 `/dev/kmsg` 存在。Kubelet 会使用它来实现一些日志记录功能，默认情况下它在容器中是不存在的。
```
cat <<EOF > /etc/rc.local
#!/bin/sh -e

if [ !  -e /dev/kmsg ]; then
    ln -s /dev/console /dev/kmsg 
fi
mount --make-rshared /
EOF
```
添加可自行权限并重启容器：`chmod +x /etc/rc.local && reboot`  
Step 4：准备容器环境，在容器中执行以下命令，安装依赖：
`apt install -y curl iptables`
> 个别 lxc 模版缺少 `iptables` `openssh-server`，需要手动安装

Step 5：安装 K3s
```
步驟1：裝 k3s Server（停用 Flannel）
  └─ 這裡可以插入：把 kubeconfig 複製到本機
步驟2：裝 Helm
步驟3：裝 Cilium
步驟4：加入另外兩台 Agent
步驟5：裝 Istio
```

通过安装脚本一键安装：
停用traefik、停用Flannel
```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
  --flannel-backend=none \
  --disable-network-policy \
  --disable-kube-proxy \
  --disable=traefik \
  --disable=servicelb \
  --write-kubeconfig-mode 644" sh -
```

裝完後設定 kubectl：
```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes

## 到另一台VM
mkdir -p ~/.kube
scp root@<Server node的IP>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i '' 's/127.0.0.1/<Server node的實際IP>/' ~/.kube/config

## 修改文件中的 IP 地址为容器的实际地址。然后测试连接：
kubectl get pods --all-namespaces
```

**這時節點狀態會是 `NotReady`，這是正常的**——因為還沒有 CNI，先不用管，繼續下一步。
記下這台主機的 IP（例如 `10.0.0.101`），以及取得 node token：
```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

裝 Helm（如果還沒裝）
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

用 Helm 裝 Cilium
```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium \
  --namespace kube-system \
  --set operator.replicas=1 \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=10.0.0.101 \
  --set k8sServicePort=6443 \
  --set ipam.mode=kubernetes
```

把 `10.0.0.101` 換成你第一台主機實際的 IP。
確認 Cilium 部署完成：
```bash
kubectl rollout status daemonset/cilium -n kube-system --timeout=120s
kubectl get nodes
```
這時節點應該變成 `Ready` 了。

步驟 4：把另外兩台加入叢集（Agent node）
在**第二台、第三台**機器上分別執行：
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://10.0.0.101:6443 K3S_TOKEN=<步驟1取得的token> sh -
```

回到第一台，確認三個節點都加入且都是 `Ready`：
```bash
kubectl get nodes
```

Step 6. 安裝Istio
下載 istioctl：
```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
sudo cp bin/istioctl /usr/local/bin/
istioctl version
```
安裝 Istio 控制平面：
```bash
istioctl install --set profile=demo -y
```
確認狀態：應該看到 `istiod`、`istio-ingressgateway` 都是 `Running`
```bash
kubectl get pods -n istio-system
```

Step 8：部署测试应用
部署一个简单的 Nginx 服务：
`kubectl create deployment nginx --image=nginx kubectl expose deployment nginx --port=80 --type=NodePort`

查询服务端口，访问应用：
`kubectl get services`
常见问题排查
- **网络不可达**：检查容器网络配置是否正确
- **K3s 启动失败**：使用 `journalctl -u k3s` 查看日志
- **kubectl 无法连接**：确认 `kubeconfig` 文件路径和权限无误
总结
将 K3s 部署在 Proxmox 容器中，是一种轻量、灵活、经济的 Kubernetes 实践方式。无论你是个人爱好者，还是中小企业探索容器化落地，这一方案都值得一试。
拥抱边缘计算，从这一套组合方案开始，让 Kubernetes 部署变得简单、高效！