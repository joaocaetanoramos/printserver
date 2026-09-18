#!/bin/bash
# =============================================
# IP fixo do print server
#   Ethernet -> /etc/network/interfaces (ifupdown)
#   WiFi     -> NetworkManager (nmcli)
# Aplica sem derrubar a sessao SSH (eth); no wifi
# a conexao reinicia por alguns segundos.
# =============================================
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root (sudo -i)."
    exit 1
fi

ask() { local v; read -e -i "$2" -r -p "$1: " v; echo "${v:-$2}"; }

DEV=$(ip -4 route show default | awk '{print $5; exit}')
if [ -z "$DEV" ]; then
    echo "Nenhuma rota default ativa. Conecte o cabo ou use ps-wifi primeiro."
    exit 1
fi

IPCIDR=$(ip -4 -o addr show dev "$DEV" | awk '$3=="inet"{print $4; exit}')
[ -z "$IPCIDR" ] && { echo "Sem IP em $DEV."; exit 1; }
GW=$(ip -4 route show default | awk '{print $3; exit}')
DNS=$(awk '/^nameserver/{printf "%s ",$2}' /etc/resolv.conf)

if [ -d "/sys/class/net/$DEV/phy80211" ]; then
    # ---------------- WiFi (NetworkManager) ----------------
    CON=$(nmcli -t -f NAME,DEVICE con show --active | awk -F: -v d="$DEV" '$2==d{print $1; exit}')
    [ -z "$CON" ] && { echo "Conexao NetworkManager ativa nao identificada."; exit 1; }

    echo "Interface WiFi: $DEV (conexao '$CON')"
    echo "MAC: $(cat /sys/class/net/$DEV/address)  <- use em reserva DHCP no roteador"
    echo ""

    NW_IP=$(ask "IP fixo (ex: $IPCIDR)" "$IPCIDR")
    GW2=$(ask "Gateway" "$GW")
    DNSW=$(ask "DNS (separados por espaco)" "${DNS:-8.8.8.8 8.8.4.4}")

    echo ""
    echo "Aplicando via NetworkManager..."
    mkdir -p /root/net-backup
    nmcli con show "$CON" > "/root/net-backup/${CON}.$(date +%Y%m%d_%H%M%S)"
    nmcli con modify "$CON" ipv4.method manual ipv4.addresses "$NW_IP" ipv4.gateway "$GW2" ipv4.dns "$DNSW"
    echo "Reconectando (a sessao SSH cai por segundos)..."
    nmcli con up "$CON"
    echo ""
    echo "Novo IP: $NW_IP"
    echo "Dica: reserva DHCP no roteador pela MAC acima evita este passo no futuro."
else
    # ---------------- Ethernet (ifupdown) ----------------
    echo "Interface Ethernet: $DEV"

    NW_IP=$(ask "IP fixo (ex: $IPCIDR)" "$IPCIDR")
    GW2=$(ask "Gateway" "$GW")
    MASKN=$(ask "Mascara (ex: 255.255.255.0)" "255.255.255.0")
    DNSW=$(ask "DNS (separados por espaco)" "${DNS:-8.8.8.8 8.8.4.4}")

    echo ""
    echo "Gravando /etc/network/interfaces..."
    mkdir -p /root/net-backup
    cp /etc/network/interfaces "/root/net-backup/interfaces.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
    cat > /etc/network/interfaces <<EOF
# Gerado por ps-ip (backup em /root/net-backup)
auto lo
iface lo inet loopback

auto $DEV
iface $DEV inet static
    address $NW_IP
    netmask $MASKN
    gateway $GW2
    dns-nameservers $DNSW
EOF

    cp /etc/resolv.conf "/root/net-backup/resolv.conf.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
    printf '%s\n' $DNSW | sed 's/^/nameserver /' > /etc/resolv.conf

    echo "Aplicando sem derrubar a sessao..."
    ip addr replace "$NW_IP" dev "$DEV" || true
    ip route replace default via "$GW2" || true

    echo ""
    echo "Novo IP: $NW_IP"
    echo "Depois de um reboot a configuracao fica definitiva."
fi