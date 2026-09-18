#!/bin/bash
# =============================================
# Instalador - Print Server Debian
# =============================================
set -e

_PS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
_REPO_DIR="$(dirname "$(dirname "$_PS_SCRIPT")")"
. "$_REPO_DIR/lib/i18n.sh"

# GitHub Contents API nao preserva o bit de execucao: ignora o modo dos
# arquivos para o git pull nao abortar sempre que o chmod +x roda.
git -C "$_REPO_DIR" config core.fileMode false 2>/dev/null || true

if [ "$(id -u)" -ne 0 ]; then
    echo "$(t ROOT_ERR)"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "=========================================="
echo "$(t INST_TITLE)"
echo "=========================================="

# ---------------------------------------------
# 1. Atualizar sistema
# ---------------------------------------------
echo "$(t INST_STEP1)"
apt-get update
apt-get upgrade -y

# ---------------------------------------------
# 2. CUPS e servicos
# ---------------------------------------------
echo "$(t INST_STEP2)"
apt-get install -y \
    cups cups-filters cups-client cups-browsed ipp-usb \
    network-manager

# ---------------------------------------------
# 3. Drivers (HP, Epson, Brother laser, termica, genericas)
# ---------------------------------------------
echo "$(t INST_STEP3)"
apt-get install -y \
    printer-driver-gutenprint printer-driver-postscript-hp hplip \
    printer-driver-brlaser printer-driver-escpr \
    printer-driver-foo2zjs

# ---------------------------------------------
# 4. Avahi (descoberta de rede)
# ---------------------------------------------
echo "$(t INST_STEP4)"
apt-get install -y avahi-daemon avahi-discover libnss-mdns

sed -i 's/hosts:.*/hosts:          files mdns4_minimal [NOTFOUND=return] dns mdns4/' /etc/nsswitch.conf

# ---------------------------------------------
# 5. Samba (compartilhamento Windows legado)
# ---------------------------------------------
echo "$(t INST_STEP5)"
apt-get install -y samba

# ---------------------------------------------
# 6. Firewall
# ---------------------------------------------
echo "$(t INST_STEP6)"
apt-get install -y ufw

# =============================================
# Configuracoes
# =============================================

# --- CUPS: liberar acesso pela rede (porta 631)
if [ -f /etc/cups/cupsd.conf ]; then
    cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.orig
fi
if ! grep -q '^Listen \*:631' /etc/cups/cupsd.conf 2>/dev/null; then
    if grep -q '^Listen' /etc/cups/cupsd.conf 2>/dev/null; then
        sed -i 's/^Listen .*/Listen *:631/' /etc/cups/cupsd.conf
    else
        echo 'Listen *:631' >> /etc/cups/cupsd.conf
    fi
fi
cupsctl --remote-admin --remote-any 2>/dev/null || \
    sed -i 's/Allow localhost$/Allow @LOCAL/' /etc/cups/cupsd.conf

# --- Avahi
cp "$_REPO_DIR/configs/avahi-daemon.conf" /etc/avahi/avahi-daemon.conf

# --- Samba
cp /etc/samba/smb.conf /etc/samba/smb.conf.orig 2>/dev/null || true
cp "$_REPO_DIR/configs/smb.conf" /etc/samba/smb.conf
mkdir -p /var/spool/samba
chmod 1777 /var/spool/samba
mkdir -p /var/lib/samba/printers
chmod 755 /var/lib/samba/printers

# --- Usuario admin do CUPS (para usar a UI web e adicionar impressoras)
ADMIN_USER="${ADMIN_USER:-admin}"
if ! id "$ADMIN_USER" >/dev/null 2>&1 && [ -t 0 ]; then
    echo "$(t INST_ADMIN_MISSING)"
    read -r -p "$(t INST_ADMIN_PROMPT)" ADMIN_USER
fi
if ! id "$ADMIN_USER" >/dev/null 2>&1; then
    ADMIN_USER="$(getent passwd 1000 | cut -d: -f1)"
fi
if id "$ADMIN_USER" >/dev/null 2>&1; then
    usermod -aG lpadmin "$ADMIN_USER"
    tf INST_ADMIN_ADDED "$ADMIN_USER"
else
    tf INST_ADMIN_ERR "${ADMIN_USER:-(empty)}"
    echo "  usermod -aG lpadmin <username>  $(t INST_ADMIN_HINT)"
fi

# --- Habilitar e iniciar servicos
echo "$(t INST_ENABLE)"
systemctl enable cups cups-browsed avahi-daemon smbd nmbd
systemctl restart cups cups-browsed avahi-daemon smbd nmbd

# --- Atalhos em /usr/local/bin (rode: ps-status, ps-logs, ps-backup...)
for s in "$_REPO_DIR"/scripts/*.sh; do
    chmod +x "$s"
    ln -sf "$s" "/usr/local/bin/ps-$(basename "$s" .sh)"
done
echo "$(t INST_SHORTCUTS)"

echo ""
echo "=========================================="
echo "$(t INST_DONE)"
echo "=========================================="
echo "$(t INST_CUPS_URL)"
echo "$(t INST_ACCESS)"
ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print "     ("$2") http://"$4}'
echo "$(t INST_FIRMWARE)"
echo ""