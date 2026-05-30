---
title: k8s整理
toc: true
date: 2026-05-30
---
| Feature                      | **KubeSolo**       | **k3s**                  | **MicroK8s**         | **k0s**              |
| ---------------------------- | ------------------ | ------------------------ | -------------------- | -------------------- |
| Architecture                 | Single-node only   | Multi-node capable       | Multi-node capable   | Multi-node capable   |
| Resource Usage               | **==<200MB RAM==** | around 500MB+ RAM        | 600MB+ RAM           | around 300–400MB RAM |
| etcd                         | No etcd            | Optionally embedded etcd | Embedded Dqlite/etcd | Embedded etcd        |
| Cluster Support              | No                 | Yes                      | Yes                  | Yes                  |
| Helm/CRD Support             | Yes                | Yes                      | Yes                  | Yes                  |
| Designed for Edge            | Yes                | Yes                      | Yes                  | Yes                  |
| System Requirements          | Ultra-low          | Moderate                 | Moderate             | Moderate             |
| Read-only Filesystem Support | Yes                | Partial                  | No                   | Partial              |
Talos Omni On-Prem