#!/bin/bash
# =============================================
# Bootstrap - Print Server Debian
# Baixa o repo e roda a instalacao
# One-liner: wget -qO- <this repo raw URL> | bash
# =============================================
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root (sudo -i)."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[0/4] Atualizando lista de pacotes..."
apt-get update

echo "[1/4] Instalando git..."
apt-get install -y git

echo "[2/4] Baixando o repo do printserver..."
if [ -d /opt/printserver/.git ]; then
    git -C /opt/printserver pull
else
    git clone https://github.com/joaocaetanoramos/printserver.git /opt/printserver
fi

echo "[3/4] Rodando instalador..."
cd /opt/printserver
bash scripts/install.sh

echo "[4/4] Configurando firewall..."
bash scripts/firewall.sh

echo ""
echo "Pronto! Veja o status:"
bash scripts/status.sh
echo ""
echo "O que falta na mao (veja o README):"
echo "  1. Adicionar as impressoras pela UI do CUPS: http://localhost:631"
echo "  2. HP: hp-setup -i | Brother: baixar .deb do site | Zebra/genérica: scripts/add-raw-printer.sh"
echo ""