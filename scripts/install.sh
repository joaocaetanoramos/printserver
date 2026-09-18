#!/bin/bash
# =============================================
# Instalador - Print Server Debian (CUPS+Avahi+Samba+UFW)
# Executar como ROOT (via bootstrap.sh ou manualmente)
# =============================================
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root (sudo -i)."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=========================================="
echo "  Print Server - Instalacao"
echo "=========================================="

# ---------------------------------------------
# 1. Atualizar sistema
# ---------------------------------------------
echo "[1/6] Atualizando sistema..."
apt-get update
apt-get upgrade -y

# ---------------------------------------------
# 2. CUPS e servicos
# ---------------------------------------------
echo "[2/6] Instalando CUPS e dependencias..."
apt-get install -y \
    cups \
    cups-filters \
    cups-client \
    cups-pdf \
    cups-browsed \
    ipp-usb

# ---------------------------------------------
# 3. Drivers (HP, Epson, Brother laser, termica, genericas)
# ---------------------------------------------
echo "[3/6] Instalando drivers..."
apt-get install -y \
    printer-driver-gutenprint \
    printer-driver-postscript-hp \
    hplip \
    printer-driver-brlaser \
    printer-driver-escpr \
    printer-driver-zj-58 \
    printer-driver-foo2zjs

# ---------------------------------------------
# 4. Avahi (descoberta de rede)
# ---------------------------------------------
echo "[4/6] Instalando Avahi..."
apt-get install -y \
    avahi-daemon \
    avahi-discover \
    libnss-mdns

# Habilitar mDNS no nsswitch
sed -i 's/hosts:.*/hosts:          files mdns4_minimal [NOTFOUND=return] dns mdns4/' /etc/nsswitch.conf

# ---------------------------------------------
# 5. Samba (compartilhamento Windows legado)
# ---------------------------------------------
echo "[5/6] Instalando Samba..."
apt-get install -y samba

# ---------------------------------------------
# 6. Firewall
# ---------------------------------------------
echo "[6/6] Instalando UFW..."
apt-get install -y ufw

# =============================================
# Configuracoes
# =============================================

# --- CUPS: liberar acesso pela rede (porta 631)
if [ -f /etc/cups/cupsd.conf ]; then
    cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.orig
fi
if ! grep -q '^Listen \*:631' /etc/cups/cupsd.conf 2>/dev/null; then
    if grep -q '^Listen' /etc/cups/cupsd.conf; then
        sed -i 's/^Listen .*/Listen *:631/' /etc/cups/cupsd.conf
    else
        echo 'Listen *:631' >> /etc/cups/cupsd.conf
    fi
fi

# --- Avahi
cp "$BASE_DIR/configs/avahi-daemon.conf" /etc/avahi/avahi-daemon.conf

# --- Samba
cp /etc/samba/smb.conf /etc/samba/smb.conf.orig 2>/dev/null || true
cp "$BASE_DIR/configs/smb.conf" /etc/samba/smb.conf
mkdir -p /var/spool/samba
chmod 1777 /var/spool/samba
mkdir -p /var/lib/samba/printers
chmod 755 /var/lib/samba/printers

# --- Usuario admin do CUPS (para usar a UI web e adicionar impressoras)
ADMIN_USER=admin
if ! id "$ADMIN_USER" >/dev/null 2>&1; then
    echo "> Usuario 'admin' nao econtrado."
    if [ -t 0 ]; then
        read -r -p "> Nome do usuario para dar admin do CUPS (nao use root): " ADMIN_USER
    fi
fi
if id "$ADMIN_USER" >/dev/null 2>&1; then
    usermod -aG lpadmin "$ADMIN_USER"
    echo "Usuario '$ADMIN_USER' adicionado ao grupo lpadmin."
else
    echo "! Usuario '$ADMIN_USER' nao existe. Crie-o ou rode novamente: usermod -aG lpadmin <usuario>"
fi

# --- Habilitar e iniciar servicos
echo "Habilitando servicos..."
systemctl enable cups cups-browsed avahi-daemon smbd nmbd
systemctl restart cups cups-browsed avahi-daemon smbd nmbd

echo ""
echo "=========================================="
echo "  Instalacao concluida!"
echo "=========================================="
echo "CUPS:  http://localhost:631  (ou http://IP-DO-SERVIDOR:631)"
echo "Imp firmware de alguns modeles foo2zjs pode precisar de 'getweb' - veja README."
echo ""