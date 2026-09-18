#!/bin/bash
# Diagnostico completo do print server
echo "=== Dispositivos de impressao detectados ==="
lpinfo -v 2>/dev/null

echo ""
echo "=== Portas abrindo ==="
ss -tlnp 2>/dev/null | grep -E ':(631|139|445|9100)\b' || echo "nada escutando"

echo ""
echo "=== Impressoras da rede via Avahi (IPP) ==="
avahi-browse -rt _ipp._tcp 2>/dev/null || echo "avahi-browse indisponivel"

echo ""
echo "=== Config do Samba (teste) ==="
testparm -s 2>/dev/null | head -20

echo ""
echo "=== Log de erros do CUPS (ultimas 30 linhas) ==="
tail -30 /var/log/cups/error_log 2>/dev/null