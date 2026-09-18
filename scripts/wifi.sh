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
CONN_OK=0
LAST_ERR=""
for KM in auto wpa-psk sae; do
    if [ "$KM" = auto ]; then
        OUT=$(nmcli dev wifi connect "$SSID" password "$PW" ifname "$DEV" 2>&1) && CONN_OK=1
    else
        OUT=$(nmcli dev wifi connect "$SSID" password "$PW" ifname "$DEV" wifi-sec.key-mgmt "$KM" 2>&1) && CONN_OK=1
    fi
    LAST_ERR=$OUT
    if [ "$CONN_OK" = 1 ]; then break; fi
done

if [ "$CONN_OK" != 1 ]; then
    nmcli con delete id "$SSID" >/dev/null 2>&1
    LAST_ERR=$(nmcli dev wifi connect "$SSID" password "$PW" ifname "$DEV" wifi-sec.key-mgmt wpa-psk 2>&1) && CONN_OK=1
fi

if [ "$CONN_OK" != 1 ]; then
    echo ""
    tf WIFI_FAIL "$SSID"
    echo "$LAST_ERR" | sed 's/^/     /'
    echo ""
    nmcli dev status || true
    exit 1
fi

IP=""
for _ in $(seq 1 20); do
    IP=$(ip -4 -o addr show dev "$DEV" scope global | awk '{print $4}' | cut -d/ -f1)
    [ -n "$IP" ] && break
    sleep 1
done

echo ""
if [ -n "$IP" ]; then
    tf WIFI_OK "$SSID"
    echo "  IP: $(echo "$IP")  GW: $(ip route | awk '/default/{print $3; exit}')"
else
    echo "$(t WIFI_NODHCP)"
    nmcli dev status || true
    exit 1
fi