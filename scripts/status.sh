#!/bin/bash
# Verificacao rapida do print server
echo "=========================================="
echo "  Print Server - Status"
echo "=========================================="

echo ">>> CUPS:"
systemctl is-active cups && echo "   Ativo" || echo "   INATIVO"

echo ">>> cups-browsed (descobre impressoras de rede):"
systemctl is-active cups-browsed && echo "   Ativo" || echo "   INATIVO"

echo ">>> Avahi:"
systemctl is-active avahi-daemon && echo "   Ativo" || echo "   INATIVO"

echo ">>> Samba:"
systemctl is-active smbd && echo "   Ativo" || echo "   INATIVO"

echo ">>> Firewall:"
ufw status verbose | head -4

echo ">>> Impressoras configuradas:"
lpstat -p 2>/dev/null || echo "   Nenhuma impressora configurada"

echo ">>> Fila:"
lpstat -o 2>/dev/null || echo "   Fila vazia"

echo ">>> Rede:"
ip -4 addr show scope global | grep inet