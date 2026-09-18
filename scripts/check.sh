#!/bin/bash
# Diagnostico completo do print server
_PS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
_REPO_DIR="$(dirname "$(dirname "$_PS_SCRIPT")")"
. "$_REPO_DIR/lib/i18n.sh"

echo "$(t CHECK_DEVICES)"
lpinfo -v 2>/dev/null

echo ""
echo "$(t CHECK_PORTS)"
ss -tlnp 2>/dev/null | grep -E ':(631|139|445|9100)\b' || echo "$(t CHECK_NOTHING)"

echo ""
echo "$(t CHECK_AVAHI)"
avahi-browse -rt _ipp._tcp 2>/dev/null || echo "$(t CHECK_AVAHI_NA)"

echo ""
echo "$(t CHECK_SAMBA)"
testparm -s 2>/dev/null | head -20

echo ""
echo "$(t CHECK_LOG)"
tail -30 /var/log/cups/error_log 2>/dev/null