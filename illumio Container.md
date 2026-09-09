---
title: illumio Container
toc: true
date: 2026-09-04
---
Illumio 官方現在把 Cilium + Hubble 描述為 Agentless Containers 的推薦 CNI telemetry 

ingress gateway L3，只能做Exgress  
```
Cilium = 怎麼送封包
Illumio = 哪些 workload / application 可以互通
Istio = service 怎麼安全地呼叫 service，以及 HTTP/gRPC 層能做什麼
微分段做 egress 不會天然破壞 Service Mesh，但你必須把 sidecar、control plane、egress gateway 都視為 policy path 的一部分；否則很容易把 mesh 自己需要的流量一起擋掉。
```

|架構|典型情境|
|---|---|
|**Cilium only**|只需要 CNI、NetworkPolicy、eBPF visibility、L3/L4 segmentation|
|**Cilium + Istio**|需要 mTLS、service identity、HTTP/gRPC routing、L7 authorization|
|**Cilium + Cilium Service Mesh**|想減少額外 mesh 元件、利用 eBPF/Envoy 整合做 L7/service mesh|

CoreDNS
一次Helm安裝替Cluster塞上Kubelink，並且在每一個Node自動塞上一個C-VEN Pod
```
Kubernetes Cluster
├─ Kubelink
│    └─ 監看 Kubernetes API
├─ Node 1
│    ├─ App Pod
│    ├─ App Pod
│    └─ C-VEN Pod
├─ Node 2
│    ├─ App Pod
│    └─ C-VEN Pod
└─ Node 3
     ├─ App Pod
     └─ C-VEN Pod
```


illumio 的Helm 是針對一個Node去安裝，C-VEN 
iptable kubelink 