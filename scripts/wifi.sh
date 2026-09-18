#!/bin/bash
# =============================================
# Conecta o servidor ao WiFi (NetworkManager)
# Uso: ps-wifi              -> menu interativo
#      ps-wifi SSID SENHA   -> conexao direta
# =============================================
set -e

_PS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
_REPO_DIR="$(dirname "$(dirname "$_PS_SCRIPT")")"
. "$_REPO_DIR/lib/i18n.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "$(t ROOT_ERR)"
    exit 1
fi

if ! command -v nmcli >/dev/null 2>&1; then
    echo "$(t WIFI_NM_MISSING)"
    exit 1
fi

DEV=$(nmcli -t -f DEVICE,TYPE dev status | awk -F: '$2 == "wifi" {print $1}' | head -1)
if [ -z "$DEV" ]; then
    echo "$(t WIFI_NODEV)"
    nmcli dev status || true
    exit 1
fi

nmcli radio wifi on

SSID="$1"
PW="$2"

if [ -z "$SSID" ]; then
    echo "$(t WIFI_SCAN)"
    nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes >/tmp/wifi.list 2>/dev/null || true
    if [ ! -s /tmp/wifi.list ]; then
        echo "$(t WIFI_NONE)"
        exit 1
    fi
    grep -v '^--$' /tmp/wifi.list | awk -F: '!seen[$1]++' | nl -s ') ' | cut -c1-90
    echo ""
    read -r -p "$(t WIFI_CHOOSE)" N
    case "$N" in
        *[!0-9]*) echo "$(t WIFI_INVALID)"; exit 1 ;;
    esac
    SSID=$(grep -v '^--$' /tmp/wifi.list | awk -F: '!seen[$1]++' | sed -n "${N}p" | cut -d: -f1 | sed 's/\\\\/\\/g')
    [ -z "$SSID" ] && echo "$(t WIFI_INVALID)" && exit 1
fi

if [ -z "$PW" ]; then
    read -r -s -p "$(t WIFI_PASS)" PW
    echo ""
fi

tf WIFI_CONNECT "$SSID"
nmcli dev wifi connect "$SSID" password "$PW" ifname "$DEV"

echo ""
tf WIFI_OK "$SSID"
ip -4 addr show "$DEV" | grep inet