#!/bin/bash
# Backup das configuracoes do print server
set -e

_PS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
_REPO_DIR="$(dirname "$(dirname "$_PS_SCRIPT")")"
. "$_REPO_DIR/lib/i18n.sh"

BACKUP_DIR="/root/printserver-backup"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

cp /etc/cups/cupsd.conf "$BACKUP_DIR/cupsd.conf.$DATE"
cp /etc/samba/smb.conf "$BACKUP_DIR/smb.conf.$DATE"
cp /etc/avahi/avahi-daemon.conf "$BACKUP_DIR/avahi-daemon.conf.$DATE"
ufw status numbered > "$BACKUP_DIR/ufw.rules.$DATE" 2>/dev/null || true

tf BACKUP_SAVED "$BACKUP_DIR"
ls -lh "$BACKUP_DIR"