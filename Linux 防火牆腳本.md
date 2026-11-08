---
title: Linux 防火牆腳本
date: 2026-11-08
---
　　在日常工作中，iptables 命令行操作不够直观，规则变更易遗忘备份，安全风险也难以快速识别。一些成熟的 AI 运维框架虽功能强大，但对重要业务而言，引入额外运行时环境会增加不必要的依赖和资源消耗，token 用量也不可控。

本文档记录了一套轻量级方案——**iptables 管理脚本 + AI 辅助分析**：

- 主脚本提供规则的查看、新增、删除、备份、回滚功能，操作直观，自动持久化
- AI 脚本按需调用，进行安全评估和优化建议，不常驻运行，无额外负担

核心思路：**该自动化的交给脚本，该判断的交给 AI**，兼顾效率与安全。

##### 一、环境准备

###### 1. 系统要求

- 操作系统：CentOS 7 / Ubuntu 22.04 LTS / Ubuntu 24.04 LTS
- 权限：需要 root 权限运行
- 网络：能正常访问外网（AI 分析需要调用 API）
- AI Key：可选，准备好七牛 AI API Key（[https://platform.qnaigc.com](https://platform.qnaigc.com/)）

###### 2. 基础依赖安装

```
＃　Ubuntu 系统
apt install iptables iptables-persistent -y
AI 分析依赖（仅 Ubuntu，可选）
＃　apt install python3 python3-requests -y

＃　CentOS 7 系统
yum install iptables-services -y
```

##### 二、脚本下载与安装

```
git clone https://gitee.com/cncsrf/firewall-manager.git
cd firewall-manager && bash firewall-manager.sh
```