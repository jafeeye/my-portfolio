---
title: jt-ipam
toc: true
date: 2026-11-05
tags:
---
```
    4  curl -fsSL https://raw.githubusercontent.com/jasoncheng7115/jt-ipam/main/scripts/bootstrap.sh | sudo bash
    5  apt-get update && sudo apt-get install -y curl
    6  update && sudo apt install -y curl
    7  apt update && sudo apt install -y curl
    8  apt update && apt install -y curl
    9  apt update && apt install -y sudo 
   10  curl -fsSL https://raw.githubusercontent.com/jasoncheng7115/jt-ipam/main/scripts/bootstrap.sh | sudo bash
   11  # 前置：最小化系統可能沒有 curl（一行式安裝需要它）
   12  sudo apt-get update && sudo apt-get install -y curl
   13  curl -fsSL https://raw.githubusercontent.com/jasoncheng7115/jt-ipam/main/scripts/bootstrap.sh   | sudo bash -s -- --tls-mode nginx --public-fqdn ipam.example.com
   14  sudo -u jtipam bash -c 'cd /opt/jt-ipam/backend; set -a; source /etc/jt-ipam/backend.env; set +a; .venv/bin/python -m app.cli.bootstrap create-admin --username admin --email admin@localhost --password-stdin --force-update'
   15  sudo -u jtipam bash -c 'cd /opt/jt-ipam/backend; set -a; source /etc/jt-ipam/backend.env; set +a; .venv/bin/python -m app.cli.bootstrap create-admin --username admin --email admin@localhost --password-2Password!0326 --force-update'
   16  sudo -u jtipam bash -c 'cd /opt/jt-ipam/backend; set -a; source /etc/jt-ipam/backend.env; set +a; .venv/bin/python -m app.cli.bootstrap create-admin --username admin --email admin@localhost --password-stdin 2Password!0326 --force-update'
   17  /etc/jt-ipam/.admin-initial-password
   18  sudo /etc/jt-ipam/.admin-initial-password
   19  sudo -u jtipam bash -c 'cd /opt/jt-ipam/backend; set -a; source /etc/jt-ipam/backend.env; set +a; \
   20    .venv/bin/python -m app.cli.bootstrap create-admin \
   21      --username admin --email admin@example.com --password-stdin --force-update'
   22  # then type the new password on stdin (≥ 12 chars)
   23  ip a
   24  sudo -u jtipam bash -c 'cd /opt/jt-ipam/backend; set -a; source /etc/jt-ipam/backend.env; set +a; \
   25  history
```