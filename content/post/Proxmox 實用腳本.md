---
title: Proxmox 實用腳本
toc: true
tags:
  - PVE
date: 2026-10-18
---
```toc
```
### 選單腳本:讀取目前目錄底下所有腳本

```bash fold
#!/usr/bin/env bash
# Blue terminal menu for Bash scripts in the current directory.
# Usage: bash script-menu.sh [directory]
# Requires: bash, dialog, GNU find/sort/readlink (standard on Proxmox).

set -uo pipefail

if [[ ! -t 0 || ! -t 1 ]]; then
  printf 'Please run this menu in an interactive terminal.\n' >&2
  exit 1
fi
if ! command -v dialog >/dev/null 2>&1; then
  printf 'Install the menu dependency first:\n  apt update && apt install -y dialog\n' >&2
  exit 1
fi

ROOT=$(cd -- "${1:-.}" && pwd -P) || exit 1
SELF=$(readlink -f -- "${BASH_SOURCE[0]}") || exit 1
SELECTION=$(mktemp) || exit 1
cleanup() {
  rm -f -- "$SELECTION"
  printf '\033[0m'
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Use a consistent blue theme, without modifying the user's dialog config.
THEME=$(mktemp) || exit 1
trap 'rm -f -- "$THEME"; cleanup' EXIT
cat > "$THEME" <<'THEME_EOF'
use_colors = ON
screen_color = (WHITE,BLUE,ON)
dialog_color = (BLACK,WHITE,OFF)
title_color = (BLUE,WHITE,ON)
border_color = (WHITE,WHITE,ON)
menubox_color = (BLACK,WHITE,OFF)
item_color = (BLACK,WHITE,OFF)
item_selected_color = (WHITE,BLUE,ON)
tag_color = (BLUE,WHITE,ON)
tag_selected_color = (WHITE,BLUE,ON)
THEME_EOF
export DIALOGRC="$THEME"

last=1
while :; do
  files=()
  options=()
  while IFS= read -r -d '' file; do
    [[ $(readlink -f -- "$file") == "$SELF" ]] && continue
    files+=("$file")
    # Keep control characters in filenames out of the terminal UI.
    label=${file##*/}
    label=${label//$'\n'/ }
    label=${label//$'\r'/ }
    label=${label//$'\t'/ }
    label=${label//$'\e'/ }
    options+=("${#files[@]}" "$label")
  done < <(find "$ROOT" -maxdepth 1 -type f -name '*.sh' -print0 | sort -zV)

  if ((${#files[@]} == 0)); then
    dialog --clear --title 'Script Menu' --msgbox \
      "No .sh scripts found in:\n$ROOT\n\nPut Bash scripts here, then launch this menu again." 12 72
    clear
    exit 0
  fi
  ((last > ${#files[@]})) && last=1

  dialog --clear --backtitle "Bash Script Launcher | $ROOT" \
    --title 'Script Menu' --ok-label 'Run' --cancel-label 'Exit' \
    --extra-button --extra-label 'Refresh' --default-item "$last" \
    --output-fd 3 --menu \
    'Up/Down: select | Enter: run | Tab: buttons | Esc: exit' \
    0 0 0 "${options[@]}" 3>"$SELECTION"
  result=$?
  case "$result" in
    3) continue ;;
    4) ;;
    *) clear; exit 0 ;;
  esac

  selected=$(<"$SELECTION")
  [[ $selected =~ ^[0-9]+$ ]] || continue
  ((selected >= 1 && selected <= ${#files[@]})) || continue
  last=$selected
  script=${files[selected-1]}
  clear
  printf 'Directory: %s\nRunning: %s\n\n' "$ROOT" "${script##*/}"

  # Separate Bash process: exit/cd/set inside a child cannot change this menu.
  # The script receives the real terminal for interactive input and output.
  # Ignore Ctrl+C in the parent while allowing the child to handle it normally.
  trap '' INT
  (trap - INT; cd -- "$ROOT" && bash -- "$script")
  status=$?
  trap 'exit 130' INT

  printf '\nExit code: %s\n' "$status"
  read -r -p 'Press Enter to return to the menu...' _ || exit 0
done

```


### PVE2ESXI:移轉至ESXi


### PVE-clone:大量複製範本生成CT


## PVE -vmid Update
https://github.com/sannier3/proxmox-vmid-updater
