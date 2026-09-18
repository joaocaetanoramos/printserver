#!/bin/bash
# Verificacao rapida do print server
_PS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
_REPO_DIR="$(dirname "$(dirname "$_PS_SCRIPT")")"
. "$_REPO_DIR/lib/i18n.sh"

echo "=========================================="
echo "$(t STATUS_HEADER)"
echo "=========================================="

echo "$(t STATUS_CUPS)"
systemctl is-active cups >/dev/null 2>&1 && echo "$(t STATUS_ACTIVE)" || echo "$(t STATUS_INACTIVE)"

echo "$(t STATUS_BROWSED)"
systemctl is-active cups-browsed >/dev/null 2>&1 && echo "$(t STATUS_ACTIVE)" || echo "$(t STATUS_INACTIVE)"

echo "$(t STATUS_AVAHI)"
systemctl is-active avahi-daemon >/dev/null 2>&1 && echo "$(t STATUS_ACTIVE)" || echo "$(t STATUS_INACTIVE)"

echo "$(t STATUS_SAMBA)"
systemctl is-active smbd >/dev/null 2>&1 && echo "$(t STATUS_ACTIVE)" || echo "$(t STATUS_INACTIVE)"

echo "$(t STATUS_FW)"
ufw status verbose 2>/dev/null | head -4

echo "$(t STATUS_PRINTERS)"
lpstat -p 2>/dev/null || echo "$(t STATUS_NONE)"

echo "$(t STATUS_QUEUE)"
lpstat -o 2>/dev/null || echo "$(t STATUS_QUEUE_EMPTY)"

echo "$(t STATUS_NET)"
ip -4 addr show scope global | grep inet