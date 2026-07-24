---
title: Colortoken
toc: true
date: 2026-07-15
---
```
/usr/bin/systemctl
```
停止/開始
```
systemctl stop ctagent
systemctl start ctagent
```



### Key Differences

Feature

Segment

Create Access Policy

**Definition**

资产的逻辑分组（例如服务器、应用程序）

控制资产之间通信/访问的规则

**Purpose**

简化管理和可视化

强化安全性和Zero Trust原则

**Usage**

按环境、角色、应用程序组织资产

指定哪些资产/Segment可以交互，以及如何交互

**Example**

将所有生产环境Web服务器分组

仅允许Web服务器访问数据库服务器

