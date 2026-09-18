#!/bin/bash
# Adicionar impressora RAW (porta 9100) - Zebra, termicas, genericas.
# Uso: add-raw-printer.sh <nome> <ip>  [porta]
# Ex.: add-raw-printer.sh zebra-100 192.168.1.150
set -e

if [ "$(id -u)" -ne 0 ] && ! id -nG | grep -qw lpadmin; then
    echo "Rode como root ou como usuario do grupo lpadmin."
    exit 1
fi

NAME="$1"
HOST="$2"
PORT="${3:-9100}"

if [ -z "$NAME" ] || [ -z "$HOST" ]; then
    echo "Uso: $0 <nome> <ip> [porta]"
    exit 1
fi

lpadmin -p "$NAME" -v "socket://$HOST:$PORT" -m raw -E
echo "Impressora '$NAME' -> socket://$HOST:$PORT (raw) adicionada."
echo "Envie ZPL/Esc-POS direto:"
echo "  lpr -P $NAME arquivo.zpl   (ou  nc $HOST $PORT < arquivo.zpl)"