---
title: cookpti
toc: true
date: 2026-05-26
---
## RockyLinux
官方預設把ppc64鎖死


更新系统并安装组件
```
## 記得先更新，不然裝完大套件因為OpenSSL系統直接炸
dnf update -y
## 安裝虛擬化套件
dnf install -y cockpit-machines libvirt qemu-kvm virt-install virt-viewer
dnf install -y wget lrzsz net-tools
```
啟動服務
```
## 啟用服務
systemctl enable --now libvirtd
systemctl enable --now cockpit.socket
## 確認服務是否正常運作
systemctl status libvirtd
systemctl status cockpit.socket
```
允许 Cockpit 使用 root 登录
```
echo "#root" | tee /etc/cockpit/disallowed-users
```
开放防火墙端口（默认无需操作）
```
firewall-cmd --add-port=9090/tcp --permanent
firewall-cmd --reload
```


## Debian 跑powerppc64

Cockpit 註冊/取消註冊虛擬機
```
sudo virsh undefine al 
sudo virsh define al1.xml
```

Cockpit xml範本 (powerppc64)
```
<domain type='qemu' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
  <name>al</name>
  <memory unit='KiB'>3145728</memory>
  <currentMemory unit='KiB'>3145728</currentMemory>
  <vcpu placement='static'>2</vcpu>

  <os>
    <type arch='ppc64' machine='pseries'>hvm</type>
    <boot dev='hd'/> 
  </os>

  <cpu mode='custom' match='exact'>
    <model fallback='allow'>POWER7</model>
  </cpu>

  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>

  <devices>
    <emulator>/usr/bin/qemu-system-ppc64</emulator>

    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/hdisk0.qcow2'/>
      <target dev='sda' bus='scsi'/>
    </disk>

    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/mnt/iso/template/iso/aix_7200-04-02-2027_1of2_072020.iso'/>
      <target dev='sdb' bus='scsi'/>
      <readonly/>
    </disk>

    <interface type='network'>
      <mac address='52:54:00:12:34:10'/>
      <source network='default'/>
      <model type='virtio'/>
    </interface>

    <console type='pty'>
      <target type='serial' port='0'/>
    </console>

  </devices>

  <qemu:commandline>
    <qemu:arg value='-serial'/>
    <qemu:arg value='mon:stdio'/>
    
    <qemu:arg value='-prom-env'/>
    <qemu:arg value='boot-command=boot cdrom:'/>
    <qemu:arg value='-prom-env'/>
    <qemu:arg value='input-device=/vdevice/vty@71000000'/>
    <qemu:arg value='-prom-env'/>
    <qemu:arg value='output-device=/vdevice/vty@71000000'/>
  </qemu:commandline>
</domain>
```










## 參考資料
- [甚麼值得買，KVM虚拟化平台搭建与Cockpit管理：基于Rocky Linux 9.6](https://post.smzdm.com/p/apw3dwl0/)
