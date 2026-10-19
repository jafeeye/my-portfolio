---
title: V2V轉換 Proxmox 與 vSphere 與 Hyper-V 互轉
toc: true
date: 2026-10-17
tags:
  - 虛擬化
  - PVE
  - ESXi
---
```toc
```

## 一、Proxmox 轉 ESXi

轉換之前要注意一下
Proxmox 要把直通的設備刪除
硬碟確保不能用同名稱的硬碟，因為放在不同磁碟會出現硬碟同名問題
轉換的虛擬機名稱不要用破折號跟點號

方法1、使用 StarWind V2V Converter (缺點速度慢)
![](static/Pasted%20image%2020261017185606.png)

方法2、使用P2V 方式
開啟VMware Converter，選擇Powered On ，藉由登入Windows 或Linux 遙控Proxmox VM 備份到ESXi
![556](static/Pasted%20image%2020261017173605.png)

方法3、土炮, `qemu-img`+`vmkfstools` 

以你那顆來源磁碟為例，**確認 VM 已關機、輸出位置有足夠空間後**，核心轉換指令是：
```
qemu-img convert -p -f raw -O vmdk \
  /dev/pve/vm-160-disk-0 \
  /有足夠空間的路徑/ws22-export.vmdk
```
上傳到 ESXi 後，再匯入成目的磁碟，例如：
```
vmkfstools -i ws22-export.vmdk ws22.vmdk -d thin
```


方法4、Proxmox 論壇網友寫的轉換腳本 [出處](https://forum.proxmox.com/threads/how-to-convert-vm-from-proxmox-to-vmware.122124/)
實測發現錯誤的vmx 會讓vSphere的登入按鈕直接便灰色

```bash
#!/bin/bash

# proxmox-vm_vmware.sh - Convert Proxmox VM to VMware format
# Author: 0zzy
# Date: 2023-09-10
# Version: 1.0
# License: MIT
#
# Description: This script converts a Proxmox VM to VMware format.
#              It can convert to VMware VMX, OVF, or OVA format.
#              It requires the ovftool command-line tool.
#              It uses the qemu-img command-line tool to convert disks.
#              It uses the jq command-line tool to parse
#
# To use the Script, run the following command:
# chmod +x proxmox-vm_vmware.sh
#
# Then run it with the required VM ID:
# ./proxmox-vm_vmware.sh -i VMID
# Example: ./proxmox-vm_vmware.sh -i 100
#
# Or with additional options:
# ./proxmox-vm_vmware.sh -i 100 -n MyVM -d /path/to/output -f ova


set -e

# Function to display usage information
function show_usage() {
    echo "Usage: $0 -i VMID [-n VM_NAME] [-d DESTINATION] [-f FORMAT]"
    echo
    echo "Options:"
    echo "  -i VMID         Proxmox VM ID to convert"
    echo "  -n VM_NAME      Name for the converted VM (default: uses original VM name)"
    echo "  -d DESTINATION  Destination directory for converted files (default: current directory)"
    echo "  -f FORMAT       VMware format (vmx, ovf, ova) (default: vmx)"
    echo "  -h              Show this help message"
    exit 1
}

# Function to check if a command exists
function check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: Required command '$1' not found. Please install it."
        exit 1
    fi
}

# Function to log messages
function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Parse command line arguments
VMID=""
VM_NAME=""
DESTINATION="$(pwd)"
FORMAT="vmx"

while getopts "i:n:d:f:h" opt; do
    case $opt in
        i) VMID="$OPTARG" ;;
        n) VM_NAME="$OPTARG" ;;
        d) DESTINATION="$OPTARG" ;;
        f) FORMAT="$OPTARG" ;;
        h) show_usage ;;
        *) show_usage ;;
    esac
done

# Check if VMID is provided
if [ -z "$VMID" ]; then
    echo "Error: VM ID is required"
    show_usage
fi

# Check required tools
check_command qemu-img
check_command jq

# Check if we're running on a Proxmox host
if [ ! -f /etc/pve/qemu-server/${VMID}.conf ]; then
    echo "Error: VM with ID ${VMID} not found on this Proxmox host"
    exit 1
fi

# Create temporary working directory
TEMP_DIR=$(mktemp -d)
log "Created temporary directory: $TEMP_DIR"

# Cleanup function
function cleanup() {
    log "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Register cleanup function to run on exit
trap cleanup EXIT

# Get VM details
if [ -z "$VM_NAME" ]; then
    VM_NAME=$(grep -E "^name:" /etc/pve/qemu-server/${VMID}.conf | cut -d' ' -f2)
    if [ -z "$VM_NAME" ]; then
        VM_NAME="vm-${VMID}"
    fi
fi

log "Converting Proxmox VM ${VMID} (${VM_NAME}) to VMware format"

# Create destination directory if it doesn't exist
mkdir -p "$DESTINATION"

# Get disk information
DISKS=$(grep -E "^(scsi|sata|ide)[0-9]+:" /etc/pve/qemu-server/${VMID}.conf | grep -v "cdrom")

# Check if VM is running
if qm status $VMID | grep -q running; then
    log "Warning: VM is currently running. It's recommended to shut it down before conversion."
    read -p "Do you want to continue anyway? (y/N): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        log "Conversion aborted"
        exit 0
    fi
fi

# Process each disk
DISK_COUNT=0
VMX_DISK_ENTRIES=""

log "Processing VM disks..."
while read -r DISK_LINE; do
    # Extract disk details
    DISK_ID=$(echo "$DISK_LINE" | cut -d: -f1)
    
    # Extract just the disk path, ignoring additional parameters
    DISK_PATH=$(echo "$DISK_LINE" | cut -d' ' -f2 | cut -d, -f1)
    
    log "Processing disk: $DISK_ID with path: $DISK_PATH"
    
    if [[ "$DISK_PATH" == *":"* ]]; then
        # Handle storage:disk format
        STORAGE=$(echo "$DISK_PATH" | cut -d: -f1)
        DISK_FILE=$(echo "$DISK_PATH" | cut -d: -f2)
        
        log "Getting full path for storage: $STORAGE, disk: $DISK_FILE"
        FULL_PATH=$(pvesm path "$STORAGE:$DISK_FILE")
    else
        # Handle direct path
        FULL_PATH="$DISK_PATH"
    fi
    
    log "Full disk path: $FULL_PATH"
    
    # Get disk format
    DISK_FORMAT=$(qemu-img info "$FULL_PATH" | grep "file format" | cut -d' ' -f3)
    log "Disk format: $DISK_FORMAT"
    
    # Convert disk to VMDK
    VMDK_NAME="${VM_NAME}-disk${DISK_COUNT}.vmdk"
    log "Converting disk $DISK_ID ($FULL_PATH) to VMDK format..."
    qemu-img convert -f "$DISK_FORMAT" -O vmdk "$FULL_PATH" "$TEMP_DIR/$VMDK_NAME"
    
    # Copy to destination
    cp "$TEMP_DIR/$VMDK_NAME" "$DESTINATION/"
    
    # Add to VMX entries
    VMX_DISK_ENTRIES+="scsi${DISK_COUNT}.present = \"TRUE\"\n"
    VMX_DISK_ENTRIES+="scsi${DISK_COUNT}.fileName = \"${VMDK_NAME}\"\n"
    
    DISK_COUNT=$((DISK_COUNT + 1))
done <<< "$DISKS"

# Get memory and CPU information
MEMORY=$(grep -E "^memory:" /etc/pve/qemu-server/${VMID}.conf | cut -d' ' -f2)
MEMORY=${MEMORY:-2048}  # Default to 2GB if not specified
CORES=$(grep -E "^cores:" /etc/pve/qemu-server/${VMID}.conf | cut -d' ' -f2)
CORES=${CORES:-1}  # Default to 1 core if not specified
SOCKETS=$(grep -E "^sockets:" /etc/pve/qemu-server/${VMID}.conf | cut -d' ' -f2)
SOCKETS=${SOCKETS:-1}  # Default to 1 socket if not specified

# Create VMX file
if [ "$FORMAT" = "vmx" ] || [ "$FORMAT" = "ovf" ] || [ "$FORMAT" = "ova" ]; then
    log "Creating VMX file..."
    cat > "$TEMP_DIR/${VM_NAME}.vmx" << EOF
.encoding = "UTF-8"
config.version = "8"
virtualHW.version = "19"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
vmci0.present = "TRUE"
displayName = "${VM_NAME}"
numvcpus = "$((CORES * SOCKETS))"
memsize = "${MEMORY}"
scsi0.virtualDev = "lsisas1068"
scsi0.present = "TRUE"
$(echo -e "$VMX_DISK_ENTRIES")
ethernet0.virtualDev = "vmxnet3"
ethernet0.present = "TRUE"
ethernet0.connectionType = "bridged"
ethernet0.startConnected = "TRUE"
ethernet0.addressType = "generated"
bios.bootDelay = "5000"
powerType.powerOff = "soft"
powerType.powerOn = "hard"
powerType.suspend = "hard"
powerType.reset = "soft"
tools.syncTime = "FALSE"
EOF

    # Copy VMX file to destination
    cp "$TEMP_DIR/${VM_NAME}.vmx" "$DESTINATION/"
    log "VMX file created at $DESTINATION/${VM_NAME}.vmx"
fi

# Convert to OVF/OVA if requested
if [ "$FORMAT" = "ovf" ] || [ "$FORMAT" = "ova" ]; then
    log "Converting to $FORMAT format..."
    check_command ovftool
    
    if [ "$FORMAT" = "ovf" ]; then
        ovftool "$DESTINATION/${VM_NAME}.vmx" "$DESTINATION/${VM_NAME}.ovf"
        log "OVF file created at $DESTINATION/${VM_NAME}.ovf"
    else
        ovftool "$DESTINATION/${VM_NAME}.vmx" "$DESTINATION/${VM_NAME}.ova"
        log "OVA file created at $DESTINATION/${VM_NAME}.ova"
        
        # Remove VMX and VMDK files as they're now in the OVA
        rm "$DESTINATION/${VM_NAME}.vmx"
        for ((i=0; i<DISK_COUNT; i++)); do
            rm "$DESTINATION/${VM_NAME}-disk${i}.vmdk"
        done
    fi
fi

log "Conversion completed successfully!"
log "VM files are available in: $DESTINATION"
```
原本的腳本有問題，下面為修改版修正scsi 編號不對問題
用法 ````
./proxmox-vm-to-esxi.sh \
  -i 160 \
  -d /mnt/pve/pve-nfs/win-ws22-hyperv \
  -p "VM Network"

```bash
#!/usr/bin/env bash

# Convert a powered-off Proxmox VE VM for import into VMware ESXi.
#
# This script creates:
#   1. One streamOptimized transfer VMDK per Proxmox disk
#   2. A valid ESXi VMX file
#   3. import-on-esxi.sh, which converts transfer VMDKs to native ESXi thin VMDKs
#
# Usage:
#   chmod +x proxmox-vm-to-esxi.sh
#   ./proxmox-vm-to-esxi.sh -i 160 -d /path/to/output
#
# After copying the output directory to an ESXi datastore:
#   cd /vmfs/volumes/<datastore>/<vm-directory>
#   chmod +x import-on-esxi.sh
#   ./import-on-esxi.sh
#   vim-cmd solo/registervm "/vmfs/volumes/<datastore>/<vm-directory>/<vm-name>.vmx"

set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage: proxmox-vm-to-esxi.sh -i VMID [-n VM_NAME] [-d DESTINATION] [-p PORTGROUP]

Options:
  -i VMID         Proxmox VM ID (required)
  -n VM_NAME      Destination VM name (default: name from Proxmox)
  -d DESTINATION  Output directory (default: current directory/VM_NAME)
  -p PORTGROUP    ESXi port group (default: VM Network)
  -h              Show this help
EOF
}

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "Required command '$1' was not found."
}

escape_vmx() {
    printf '%s' "$1" |
        sed 's/\\/\\\\/g; s/"/\\"/g'
}

VMID=''
VM_NAME=''
DESTINATION=''
PORTGROUP='VM Network'

while getopts ':i:n:d:p:h' opt; do
    case "$opt" in
        i) VMID=$OPTARG ;;
        n) VM_NAME=$OPTARG ;;
        d) DESTINATION=$OPTARG ;;
        p) PORTGROUP=$OPTARG ;;
        h)
            usage
            exit 0
            ;;
        :) die "Option -$OPTARG requires a value." ;;
        \?) die "Unknown option: -$OPTARG" ;;
    esac
done

[[ -n "$VMID" ]] || {
    usage
    die 'VM ID is required.'
}

[[ "$VMID" =~ ^[0-9]+$ ]] ||
    die 'VM ID must contain digits only.'

require_command qm
require_command pvesm
require_command qemu-img
require_command sed
require_command awk

PVE_CONFIG="/etc/pve/qemu-server/${VMID}.conf"

[[ -f "$PVE_CONFIG" ]] ||
    die "VM $VMID was not found on this Proxmox node."

if qm status "$VMID" | grep -q 'status: running'; then
    die "VM $VMID is running. Shut it down before conversion."
fi

if [[ -z "$VM_NAME" ]]; then
    VM_NAME=$(
        awk -F': *' '$1 == "name" {print $2; exit}' \
            "$PVE_CONFIG"
    )

    [[ -n "$VM_NAME" ]] ||
        VM_NAME="vm-${VMID}"
fi

FILE_NAME=$(
    printf '%s' "$VM_NAME" |
        sed 's#[/\\:*?"<>|]#-#g; s/[[:space:]]\+/-/g'
)

[[ -n "$FILE_NAME" ]] ||
    FILE_NAME="vm-${VMID}"

if [[ -z "$DESTINATION" ]]; then
    DESTINATION="$(pwd)/${FILE_NAME}"
fi

mkdir -p "$DESTINATION"
DESTINATION=$(cd "$DESTINATION" && pwd)

VMX_PATH="${DESTINATION}/${FILE_NAME}.vmx"
IMPORT_SCRIPT="${DESTINATION}/import-on-esxi.sh"

[[ ! -e "$VMX_PATH" ]] ||
    die "Output already exists: $VMX_PATH"

[[ ! -e "$IMPORT_SCRIPT" ]] ||
    die "Output already exists: $IMPORT_SCRIPT"

MEMORY=$(
    awk -F': *' '$1 == "memory" {print $2; exit}' \
        "$PVE_CONFIG"
)

CORES=$(
    awk -F': *' '$1 == "cores" {print $2; exit}' \
        "$PVE_CONFIG"
)

SOCKETS=$(
    awk -F': *' '$1 == "sockets" {print $2; exit}' \
        "$PVE_CONFIG"
)

BIOS=$(
    awk -F': *' '$1 == "bios" {print $2; exit}' \
        "$PVE_CONFIG"
)

MEMORY=${MEMORY:-2048}
CORES=${CORES:-1}
SOCKETS=${SOCKETS:-1}
NUM_VCPUS=$((CORES * SOCKETS))

mapfile -t DISK_LINES < <(
    awk '
        /^(scsi|sata|ide|virtio)[0-9]+:/ &&
        $0 !~ /(^|,)media=cdrom(,|$)/ &&
        $0 !~ /(^|,)cdrom(,|$)/ &&
        $0 !~ /: *none(,|$)/ &&
        $0 !~ /cloudinit/
    ' "$PVE_CONFIG"
)

(( ${#DISK_LINES[@]} > 0 )) ||
    die "No supported VM disks were found in $PVE_CONFIG"

(( ${#DISK_LINES[@]} <= 15 )) ||
    die 'This script supports at most 15 SCSI disks.'

DISPLAY_NAME_ESCAPED=$(escape_vmx "$VM_NAME")
PORTGROUP_ESCAPED=$(escape_vmx "$PORTGROUP")

if [[ "$BIOS" == 'ovmf' ]]; then
    VMWARE_FIRMWARE='efi'
else
    VMWARE_FIRMWARE='bios'
fi

cat >"$VMX_PATH" <<EOF
.encoding = "UTF-8"
config.version = "8"
virtualHW.version = "19"
displayName = "${DISPLAY_NAME_ESCAPED}"
numvcpus = "${NUM_VCPUS}"
memsize = "${MEMORY}"
firmware = "${VMWARE_FIRMWARE}"

pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"

scsi0.present = "TRUE"
scsi0.virtualDev = "lsisas1068"

ethernet0.present = "TRUE"
ethernet0.virtualDev = "e1000e"
ethernet0.networkName = "${PORTGROUP_ESCAPED}"
ethernet0.startConnected = "TRUE"
ethernet0.addressType = "generated"

vmci0.present = "TRUE"
tools.syncTime = "FALSE"
powerType.powerOff = "soft"
powerType.powerOn = "hard"
powerType.suspend = "hard"
powerType.reset = "soft"
uuid.action = "create"
EOF

cat >"$IMPORT_SCRIPT" <<'EOF'
#!/bin/sh
set -eu

cd "$(dirname "$0")"

command -v vmkfstools >/dev/null 2>&1 || {
    echo 'Error: Run this script from an ESXi shell.' >&2
    exit 1
}
EOF

log "Converting Proxmox VM $VMID ($VM_NAME)"
log "Output directory: $DESTINATION"

DISK_INDEX=0

for DISK_LINE in "${DISK_LINES[@]}"; do
    DISK_ID=${DISK_LINE%%:*}
    DISK_SPEC=${DISK_LINE#*:}
    DISK_SPEC=${DISK_SPEC# }
    VOLUME_ID=${DISK_SPEC%%,*}

    [[ -n "$VOLUME_ID" ]] ||
        die "Could not parse disk entry: $DISK_LINE"

    if [[ "$VOLUME_ID" == /* ]]; then
        SOURCE_PATH=$VOLUME_ID
    elif [[ "$VOLUME_ID" == *:* ]]; then
        SOURCE_PATH=$(pvesm path "$VOLUME_ID")
    else
        die "Unsupported disk reference '$VOLUME_ID'"
    fi

    [[ -e "$SOURCE_PATH" ]] ||
        die "Source disk does not exist: $SOURCE_PATH"

    SCSI_UNIT=$DISK_INDEX

    # VMware reserves SCSI unit 7 for the controller.
    if (( SCSI_UNIT >= 7 )); then
        SCSI_UNIT=$((SCSI_UNIT + 1))
    fi

    TRANSFER_VMDK="${FILE_NAME}-disk${DISK_INDEX}-transfer.vmdk"
    NATIVE_VMDK="${FILE_NAME}-disk${DISK_INDEX}.vmdk"
    TRANSFER_PATH="${DESTINATION}/${TRANSFER_VMDK}"

    [[ ! -e "$TRANSFER_PATH" ]] ||
        die "Output already exists: $TRANSFER_PATH"

    log "Disk $DISK_ID: $SOURCE_PATH"
    log "Creating transfer image: $TRANSFER_VMDK"

    qemu-img convert \
        -p \
        -O vmdk \
        -o subformat=streamOptimized,adapter_type=lsilogic \
        "$SOURCE_PATH" \
        "$TRANSFER_PATH"

    cat >>"$VMX_PATH" <<EOF

scsi0:${SCSI_UNIT}.present = "TRUE"
scsi0:${SCSI_UNIT}.fileName = "${NATIVE_VMDK}"
scsi0:${SCSI_UNIT}.deviceType = "scsi-hardDisk"
EOF

    cat >>"$IMPORT_SCRIPT" <<EOF

if [ -e "${NATIVE_VMDK}" ] ||
   [ -e "${NATIVE_VMDK%.vmdk}-flat.vmdk" ]; then
    echo "Error: Destination disk already exists: ${NATIVE_VMDK}" >&2
    exit 1
fi

echo "Importing ${TRANSFER_VMDK} -> ${NATIVE_VMDK}"

vmkfstools \
    -i "${TRANSFER_VMDK}" \
    "${NATIVE_VMDK}" \
    -d thin
EOF

    DISK_INDEX=$((DISK_INDEX + 1))
done

cat >>"$IMPORT_SCRIPT" <<EOF

echo
echo 'Disk import completed.'
echo 'Register the VM with:'
echo "vim-cmd solo/registervm \"\$(pwd)/${FILE_NAME}.vmx\""
EOF

chmod +x "$IMPORT_SCRIPT"

cat >"${DESTINATION}/README-ESXI.txt" <<EOF
Proxmox VM $VMID was exported for ESXi.

1. Copy this complete directory to an ESXi datastore.

2. Open an ESXi SSH shell and enter the directory.

3. Run:

   chmod +x import-on-esxi.sh
   ./import-on-esxi.sh

4. Register the VM:

   vim-cmd solo/registervm \
   "/vmfs/volumes/<datastore>/<directory>/${FILE_NAME}.vmx"

5. Confirm the firmware before first boot:

   Proxmox BIOS: ${BIOS:-seabios}
   VMware firmware: ${VMWARE_FIRMWARE}

Do not attach the *-transfer.vmdk files directly.
They are import sources.

After the VM boots and is verified, the *-transfer.vmdk files
may be removed.
EOF

log 'Conversion completed successfully.'
log "VMX: $VMX_PATH"
log "ESXi import script: $IMPORT_SCRIPT"
log 'Copy the complete output directory to ESXi.'
log 'Then run import-on-esxi.sh from the ESXi shell.'
```




## 二、vSphere 轉 Hyper-V
![](static/Pasted%20image%2020261017235747.png)
進到畫面安裝PowerCLI
![](static/Pasted%20image%2020261017235858.png)


## ESXi 轉 Proxmox
### 遷移: 從ESXi 
會有驅動問題，在Windows不能開機就選SATA
![](260404-pve.png)

### 遷移: P2V
1. 把目前開機的作業系統,使用對應軟體可直接熱轉換
- Disk2vhd
- StarWind V2V
2. 先不要使用上傳Proxmox功能(9.0.1.848)，不穩定速度慢
![](260404-v2v.png)



### 遷移: 轉換至ESXi
![](PixPin_2026-05-02_00-17-16.png)



## 三、Hyper-V 遷移至PVE
1. 將vhdx上傳至PVE目錄，因為UI不能直接傳vhdx，所以使用SFTP上傳
2.  輸入以下指令
```
mkdir /var/lib/vz/hdd
cd /var/lib/vz/hdd
qemu-img convert -O qcow2 WIN10.vhdx vm-103-disk0.qcow2
mv vm-103-disk0.qcow2 /var/lib/vz/images/103/
qm rescan
```
3. BIOS 選擇**OVMF(UEFI)**、**q35**，網路選擇**E1000**
4. 最後要安裝Vitro-win驅動



## 四、格式轉換
OVA = Open Virtualization Archive
OVF= Ovftool
