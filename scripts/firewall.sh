#!/bin/bash
# =============================================
# Configuracao do Firewall (UFW)
# =============================================
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root (sudo -i)."
    exit 1
fi

echo "Configurando Firewall..."

ufw default deny incoming
ufw default allow outgoing

# SSH (cuidado: nao se tranque fora!)
ufw allow 22/tcp comment 'SSH'

# CUPS / IPP (impressao)
ufw allow 631/tcp comment 'CUPS/IPP'

# Raw printing (Zebra, termica, genericas - porta 9100)
ufw allow 9100/tcp comment 'Raw Printing'

# Avahi / mDNS (descoberta de rede)
ufw allow 5353/udp comment 'Avahi/mDNS'

# Samba - NetBIOS / compartilhamento
ufw allow 137/udp comment 'Samba NetBIOS Name'
ufw allow 138/udp comment 'Samba NetBIOS Datagram'
ufw allow 139/tcp comment 'Samba NetBIOS Session'
ufw allow 445/tcp comment 'Samba File Sharing'

# Ativar
ufw --force enable

echo ""
echo "Status do Firewall:"
ufw status verbose
echo ""
echo "Firewall configurado!"