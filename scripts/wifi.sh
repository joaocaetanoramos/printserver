#!/bin/bash
# =============================================
# Conecta o servidor ao WiFi (NetworkManager)
# Uso: ps-wifi              -> menu interativo
#      ps-wifi SSID SENHA   -> conexao direta
# =============================================
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root (sudo -i)."
    exit 1
fi

if ! command -v nmcli >/dev/null 2>&1; then
    echo "Instalando NetworkManager..."
    apt-get install -y network-manager
    systemctl enable NetworkManager
    systemctl restart NetworkManager
    sleep 3
fi

DEV=$(nmcli -t -f DEVICE,TYPE dev status | awk -F: '$2 == "wifi" {print $1}' | head -1)
if [ -z "$DEV" ]; then
    echo "Nenhuma interface WiFi detectada:"
    nmcli dev status || true
    exit 1
fi

nmcli radio wifi on

SSID="$1"
PW="$2"

if [ -z "$SSID" ]; then
    echo "Procurando redes WiFi..."
    nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes >/tmp/wifi.list 2>/dev/null || true
    grep -v '^--$' /tmp/wifi.list | awk -F: '!seen[$1]++' | nl -s ') ' | cut -c1-90
    if [ ! -s /tmp/wifi.list ]; then
        echo "Nenhuma rede encontrada. Confira se a antena esta habilitada ou aproxime-se do roteador."
        exit 1
    fi
    echo ""
    read -r -p "Digite o numero da rede: " N
    case "$N" in
        *[!0-9]*) echo "Opcao invalida."; exit 1 ;;
    esac
    SSID=$(grep -v '^--$' /tmp/wifi.list | awk -F: '!seen[$1]++' | sed -n "${N}p" | cut -d: -f1 | sed 's/\\\\/\\/g')
    [ -z "$SSID" ] && echo "Opcao invalida." && exit 1
fi

if [ -z "$PW" ]; then
    read -r -s -p "Senha do WiFi: " PW
    echo ""
fi

echo "Conectando em '$SSID'..."
nmcli dev wifi connect "$SSID" password "$PW" ifname "$DEV"

echo ""
echo "Conectado a '$SSID'!"
ip -4 addr show "$DEV" | grep inet