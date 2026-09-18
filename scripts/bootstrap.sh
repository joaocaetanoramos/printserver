#!/bin/bash
# =============================================
# Bootstrap - Debian Print Server
# One-liner: wget -qO- https://raw.githubusercontent.com/joaocaetanoramos/printserver/main/scripts/bootstrap.sh | bash
# This script runs BEFORE the repo exists, so its messages stay in English.
# =============================================
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root (sudo -i)."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[0/4] Updating package lists..."
apt-get update

echo "[1/4] Installing git..."
apt-get install -y git

echo "[2/4] Downloading the printserver repo... (may ask for your GitHub credentials)"
if [ -d /opt/printserver/.git ]; then
    git -C /opt/printserver pull
else
    git clone https://github.com/joaocaetanoramos/printserver.git /opt/printserver
fi

echo "[3/4] Running installer..."
cd /opt/printserver
bash scripts/install.sh

echo "[4/4] Configuring firewall..."
bash scripts/firewall.sh

# Repo now exists: switch the closing messages to the system language
[ -f /opt/printserver/lib/i18n.sh ] && . /opt/printserver/lib/i18n.sh

echo ""
echo "$(t BOOT_DONE)"
bash scripts/status.sh
echo ""
echo "$(t BOOT_MANUAL)"
echo "$(t BOOT_MANUAL_1)"
echo "$(t BOOT_MANUAL_2)"
echo ""