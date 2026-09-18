#!/bin/bash
# =============================================
# Configuracao do Firewall (UFW)
# =============================================
set -e

_PS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
_REPO_DIR="$(dirname "$(dirname "$_PS_SCRIPT")")"
. "$_REPO_DIR/lib/i18n.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "$(t ROOT_ERR)"
    exit 1
fi

echo "$(t FW_CONFIG)"

ufw default deny incoming
ufw default allow outgoing

ufw allow 22/tcp comment 'SSH'
ufw allow 631/tcp comment 'CUPS/IPP'
ufw allow 9100/tcp comment 'Raw Printing'
ufw allow 5353/udp comment 'Avahi/mDNS'
ufw allow 137/udp comment 'Samba NetBIOS Name'
ufw allow 138/udp comment 'Samba NetBIOS Datagram'
ufw allow 139/tcp comment 'Samba NetBIOS Session'
ufw allow 445/tcp comment 'Samba File Sharing'

ufw --force enable

echo ""
echo "$(t FW_STATUS)"
ufw status verbose
echo ""
echo "$(t FW_DONE)"