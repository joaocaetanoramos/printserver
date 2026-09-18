#!/bin/bash
# Atualiza o print server a partir do repositorio
# Idempotente: roda de novo sem quebrar nada
set -e

if [ -f /opt/printserver/lib/i18n.sh ]; then
    . /opt/printserver/lib/i18n.sh
fi

if [ "$(id -u)" -ne 0 ]; then
    if [ -n "$(type -t t)" ]; then t ROOT_ERR; else echo "Run as root (sudo -i)."; fi
    exit 1
fi

if [ ! -d /opt/printserver/.git ]; then
    t UPDATE_NOREPO; echo
    t UPDATE_FIRST; echo
    exit 1
fi

echo "$(t UPDATE_PULL)"
git -C /opt/printserver pull --ff-only

echo "$(t UPDATE_APPLY)"
exec bash /opt/printserver/scripts/bootstrap.sh