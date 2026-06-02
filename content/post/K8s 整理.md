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



查pod 狀態

![](Pasted%20image%2020260602171514.png)
查log
```
kubectl describe pod finance-web -n default
```
