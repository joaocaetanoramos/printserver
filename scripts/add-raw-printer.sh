#!/bin/bash
# Adicionar impressora RAW (porta 9100) - Zebra, termicas, genericas.
# Uso: ps-add-raw-printer <nome> <ip>  [porta]
set -e

_PS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
_REPO_DIR="$(dirname "$(dirname "$_PS_SCRIPT")")"
. "$_REPO_DIR/lib/i18n.sh"

if [ "$(id -u)" -ne 0 ] && ! id -nG | grep -qw lpadmin; then
    echo "$(t RAW_PERM)"
    exit 1
fi

NAME="$1"
HOST="$2"
PORT="${3:-9100}"

if [ -z "$NAME" ] || [ -z "$HOST" ]; then
    tf RAW_USAGE "$0"
    exit 1
fi

lpadmin -p "$NAME" -v "socket://$HOST:$PORT" -m raw -E
tf RAW_ADDED "$NAME" "$HOST" "$PORT"
echo "$(t RAW_SEND)"
tf RAW_EXAMPLE "$NAME" "$HOST" "$PORT"