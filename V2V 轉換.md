---
title: V2V轉換 Proxmox 與 vSphere 與 Hyper-V 互轉
toc: true
date: 2026-10-17
tags:
  - 虛擬化
---
轉換之前要注意一下
Proxmox 要把直通的設備刪除
硬碟確保不能用同名稱的硬碟，因為放在不同磁碟會出現硬碟同名問題
轉換的虛擬機名稱不要用破折號跟點號

方法1、使用 StarWind V2V Converter (缺點速度慢)


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

