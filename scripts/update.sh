#!/bin/bash
# =============================================
# Atualiza o print server a partir do repositório
# Idempotente: roda de novo sem quebrar nada
# =============================================
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root (sudo -i)."
    exit 1
fi

if [ ! -d /opt/printserver/.git ]; then
    echo "Repositorio nao encontrado em /opt/printserver."
    echo "Instale primeiro com o one-liner do bootstrap."
    exit 1
fi

echo "[1/3] Buscando atualizacoes..."
git -C /opt/printserver pull --ff-only

echo "[2/3] Aplicando configs novamente..."
exec bash /opt/printserver/scripts/bootstrap.sh