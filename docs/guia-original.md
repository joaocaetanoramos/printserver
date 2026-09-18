# Print Server com Debian + CUPS — Guia Completo

## Índice

1.  [Preparação](#1-prepara%C3%A7%C3%A3o)
    
2.  [Instalação do Debian](#2-instala%C3%A7%C3%A3o-do-debian)
    
3.  [Script de Instalação](#3-script-de-instala%C3%A7%C3%A3o)
    
4.  [Configuração do CUPS](#4-configura%C3%A7%C3%A3o-do-cups)
    
5.  [Configuração do Avahi](#5-configura%C3%A7%C3%A3o-do-avahi)
    
6.  [Configuração do Samba](#6-configura%C3%A7%C3%A3o-do-samba)
    
7.  [Configuração do Firewall](#7-configura%C3%A7%C3%A3o-do-firewall)
    
8.  [Acesso e Gerenciamento](#8-acesso-e-gerenciamento)
    
9.  [Scripts Úteis](#9-scripts-%C3%BAteis)
    

* * *

## 1. Preparação

### 1.1 Baixar o Debian netinst

```
https://www.debian.org/distrib/netinst
```

*   Arquivo: `debian-XX.X.X-amd64-netinst.iso` (~300-500MB)
    
*   Teste AMD64 (mesmo que Intel)
    

### 1.2 Criar pendrive bootável

**No Linux:**

```bash
# Identifique o pendrive (cuidado: tudo será apagado!)
lsblk

# Grave a ISO (substitua sdX pelo seu pendrive)
sudo dd if=debian-XX.X.X-amd64-netinst.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

**No Windows:**

*   Use o [Rufus](https://rufus.ie/pt_BR/) ou [Balena Etcher](https://etcher.balena.io/)
    

* * *

## 2. Instalação do Debian

### 2.1 Boot e inicialização

1.  Boote pelo pendrive
    
2.  Selecione **"Graphical install"** ou **"Install"**
    
3.  Siga os passos:
    

### 2.2 Configurações durante a instalação

| Passo | Recomendação |
| --- | --- |
| **Idioma** | Portuguese (Brazil) |
| **Localização** | Brasil |
| **Teclado** | Português (Brasil) |
| **Rede** | Ethernet (DHCP automático) — depois você seta IP fixo |
| **Hostname** | `printserver` |
| **Domínio** | `printserver.local` (ou deixe em branco) |
| **Senha root** | Defina uma senha forte |
| **Usuário** | Crie um usuário comum (ex: `admin`) |
| **Disco** | "Guiado - usar disco inteiro" |
| **Partições** | "Todos os arquivos em uma partição" |
| **Espelho** | Brasil (deb.debian.org) |

### 2.3 Seleção de software

> ⚠️ **NÃO marque nada aqui.** Vamos instalar tudo depois via script.

Continue até finish e reinicie.

### 2.4 Primeiro boot — IP fixo

```bash
# Login como root

# Identifique o nome da interface de rede
ip a

# Edite a configuração de rede
nano /etc/network/interfaces
```

Adicione (ajuste conforme sua rede):

```
# Interface principal
auto enp0s3
iface enp0s3 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

```bash
# Reinicie a rede
systemctl restart networking

# ou reinicie o servidor
reboot
```

* * *

## 3. Script de Instalação

### 3.1 Login e preparo

```bash
# Login como root (ou sudo -i)

# Atualize o sistema
apt update && apt upgrade -y
```

### 3.2 Script completo de instalação

Copie e execute o script abaixo:

```bash
cat << 'EOF' > /opt/install-printserver.sh
#!/bin/bash

# =============================================
# Script de instalação - Print Server Debian
# Executar como ROOT
# =============================================

set -e

echo "=========================================="
echo "  Print Server - Script de Instalação"
echo "=========================================="
echo ""

# ---------------------------------------------
# 1. Atualizar sistema
# ---------------------------------------------
echo "[1/6] Atualizando sistema..."
apt update && apt upgrade -y

# ---------------------------------------------
# 2. Instalar CUPS e dependências
# ---------------------------------------------
echo "[2/6] Instalando CUPS e serviços..."
apt install -y \
    cups \
    cups-filters \
    cups-pdf \
    cups-client \
    cups-common \
    ippusbxd

# ---------------------------------------------
# 3. Instalar drivers de impressora
# ---------------------------------------------
echo "[3/6] Instalando drivers..."
apt install -y \
    printer-driver-gutenprint \
    printer-driver-all \
    hplip \
    printer-driver-zj-58 \
    printer-driver-brlaser \
    printer-driver-foo2zjs \
    printer-driver-splix \
    printer-driver-postscript-hp \
    printer-driver-pxljr

# ---------------------------------------------
# 4. Instalar Avahi (descoberta de rede)
# ---------------------------------------------
echo "[4/6] Instalando Avahi..."
apt install -y \
    avahi-daemon \
    avahi-discover \
    libnss-mdns

# Habilitar mDNS no nsswitch
sed -i 's/hosts:.*/hosts:          files mdns4_minimal [NOTFOUND=return] dns mdns4/' /etc/nsswitch.conf

# ---------------------------------------------
# 5. Instalar Samba (compartilhamento Windows)
# ---------------------------------------------
echo "[5/6] Instalando Samba..."
apt install -y samba

# ---------------------------------------------
# 6. Instalar Firewall
# ---------------------------------------------
echo "[6/6] Instalando Firewall (UFW)..."
apt install -y ufw

echo ""
echo "=========================================="
echo "  Instalação concluída!"
echo "=========================================="
echo ""
echo "Próximos passos:"
echo "  1. Edite /etc/cups/cupsd.conf"
echo "  2. Edite /etc/samba/smb.conf"
echo "  3. Configure o firewall"
echo "  4. Reinicie os serviços"
echo ""
EOF

chmod +x /opt/install-printserver.sh
bash /opt/install-printserver.sh
```

* * *

## 4. Configuração do CUPS

### 4.1 Backup do config original

```bash
cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.backup
```

### 4.2 Configuração do CUPS

```bash
cat << 'EOF' > /etc/cups/cupsd.conf
# =============================================
# Configuração do CUPS - Print Server
# =============================================

# Informações do servidor
ServerName printserver.local
ServerAdmin root@localhost

# Permitir acesso de qualquer lugar (rede local)
Listen *:631

# Log
LogLevel warn
AccessLog /var/log/cups/access_log
ErrorLog /var/log/cups/error_log
PageLog /var/log/cups/page_log

# Preservar jobs por 24 horas
PreserveJobHistory Yes
PreserveJobFiles Yes
MaxJobs 100
MaxJobTime 86400

# -----------------
# Seções de browse
# -----------------
# Permitir que o CUPS descubra impressoras na rede
BrowseRemoteProtocols dnssd
BrowseLocalProtocols dnssd

# Permitir compartilhamento de impressoras
BrowseAddress @LOCAL
BrowseAllow all

# Publicar impressoras na rede
ServerAlias *

# -----------------
# Políticas de acesso
# -----------------

# Padrão básico
DefaultPolicy default

# Conexões permitidas
Order allow,deny
Allow all

# -----------------
# Location /admin
# -----------------
<Location /admin>
    Order allow,deny
    Allow all
</Location>

# -----------------
# Location /admin/conf
# -----------------
<Location /admin/conf>
    AuthType Default
    Require user @SYSTEM
    Order allow,deny
    Allow all
</Location>

# -----------------
# Location /jobs
# -----------------
<Location /jobs>
    Order allow,deny
    Allow all
</Location>

# -----------------
# Location /printers
# -----------------
<Location /printers>
    Order allow,deny
    Allow all
</Location>

# -----------------
# Location /
# -----------------
<Location />
    Order allow,deny
    Allow all
</Location>
EOF
```

### 4.3 Habilitar e iniciar CUPS

```bash
systemctl enable cups
systemctl restart cups
```

* * *

## 5. Configuração do Avahi

### 5.1 Configuração do Avahi

```bash
cat << 'EOF' > /etc/avahi/avahi-daemon.conf
[server]
host-name=printserver
domain-name=local
use-ipv4=yes
use-ipv6=no
ratelimit-interval-usec=1000000
ratelimit-burst=1000

[publish]
publish-hinfo=no
publish-workstation=no

[reflector]
enable-reflector=yes
reflect-ipv=no

[rlimits]
rlimit-as=-1
rlimit-core=-1
rlimit-data=-1
rlimit-fsize=-1
rlimit-nofile=10000
rlimit-stack=-1
rlimit-nproc=3
EOF
```

### 5.2 Habilitar e iniciar Avahi

```bash
systemctl enable avahi-daemon
systemctl restart avahi-daemon
```

* * *

## 6. Configuração do Samba

### 6.1 Backup do config original

```bash
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
```

### 6.2 Configuração do Samba

```bash
cat << 'EOF' > /etc/samba/smb.conf
# =============================================
# Configuração do Samba - Print Server
# =============================================

[global]
   workgroup = WORKGROUP
   server string = Print Server
   server role = standalone server
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file
   panic action = /usr/share/samba/panic-action %d

   # Segurança
   map to guest = Bad User
   dns proxy = No

   # Performance
   socket options = TCP_NODELAY IPTOS_LOWDELAY
   read raw = Yes
   write raw = Yes
   use sendfile = Yes
   aio read size = 16384
   aio write size = 16384

   # Permitir que o Samba anuncie impressoras
   printcap name = cups
   printing = cups
   load printers = Yes

[printers]
   comment = All Printers
   path = /var/spool/samba
   browseable = Yes
   read only = No
   guest ok = Yes
   writable = No
   printable = Yes
   printer admin = root, @lpadmin

[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = Yes
   read only = No
   guest ok = Yes
EOF
```

### 6.3 Criar diretório de spool

```bash
mkdir -p /var/spool/samba
chmod 1777 /var/spool/samba
mkdir -p /var/lib/samba/printers
chmod 755 /var/lib/samba/printers
```

### 6.4 Habilitar e iniciar Samba

```bash
systemctl enable smbd nmbd
systemctl restart smbd nmbd
```

* * *

## 7. Configuração do Firewall (UFW)

### 7.1 Script de configuração do firewall

```bash
cat << 'EOF' > /opt/configure-firewall.sh
#!/bin/bash
# =============================================
# Script - Configuração do Firewall (UFW)
# =============================================

echo "=========================================="
echo "  Configurando Firewall"
echo "=========================================="

# Políticas padrão
ufw default deny incoming
ufw default allow outgoing

# SSH (cuidado: não se tranque fora!)
ufw allow 22/tcp comment 'SSH'

# CUPS (interface web)
ufw allow 631/tcp comment 'CUPS Web Interface'

# CUPS - IPP (impressão via rede)
ufw allow 631/udp comment 'CUPS IPP'

# Avahi (descoberta de rede)
ufw allow 5353/udp comment 'Avahi/mDNS'

# Samba - NetBIOS
ufw allow 137/udp comment 'Samba NetBIOS Name'
ufw allow 138/udp comment 'Samba NetBIOS Datagram'

# Samba - Compartilhamento de arquivos
ufw allow 139/tcp comment 'Samba File Sharing'
ufw allow 445/tcp comment 'Samba File Sharing'

# Raw printing (algumas impressoras)
ufw allow 9100/tcp comment 'Raw Printing'

# Ativar firewall
ufw --force enable

echo ""
echo "Status do Firewall:"
ufw status verbose
echo ""
echo "=========================================="
echo "  Firewall configurado!"
echo "=========================================="
EOF

chmod +x /opt/configure-firewall.sh
bash /opt/configure-firewall.sh
```

* * *

## 8. Acesso e Gerenciamento

### 8.1 Acesso à interface web do CUPS

```
http://192.168.1.100:631
```

**Primera coisa a fazer:** clique em **"Administration"** → **"Add Printer"**

### 8.2 Testar conexão

**De outro PC na rede:**

```bash
# Testar se o CUPS está respondendo
curl http://192.168.1.100:631

# Ver impressoras发现的 na rede
nmap -p 631 192.168.1.0/24
```

### 8.3 Reiniciar todos os serviços

```bash
cat << 'EOF' > /opt/restart-services.sh
#!/bin/bash
echo "Reiniciando serviços..."

systemctl restart cups
systemctl restart avahi-daemon
systemctl restart smbd nmbd
systemctl restart ufw

echo "Status dos serviços:"
systemctl status cups --no-pager
systemctl status avahi-daemon --no-pager
systemctl status smbd --no-pager
EOF

chmod +x /opt/restart-services.sh
```

### 8.4 Status rápido

```bash
cat << 'EOF' > /opt/status.sh
#!/bin/bash
echo "=========================================="
echo "  Print Server - Status"
echo "=========================================="
echo ""
echo ">>> CUPS:"
systemctl is-active cups && echo "   ✅ Ativo" || echo "   ❌ Inativo"
echo ""
echo ">>> Avahi:"
systemctl is-active avahi-daemon && echo "   ✅ Ativo" || echo "   ❌ Inativo"
echo ""
echo ">>> Samba:"
systemctl is-active smbd && echo "   ✅ Ativo" || echo "   ❌ Inativo"
echo ""
echo ">>> Firewall:"
ufw status | head -3
echo ""
echo ">>> Impressoras encontradas:"
lpstat -a 2>/dev/null || echo "   Nenhuma impressora configurada"
echo ""
echo ">>> Rede:"
ip a | grep inet | grep -v 127.0.0.1
echo ""
echo "=========================================="
EOF

chmod +x /opt/status.sh
/opt/status.sh
```

* * *

## 9. Scripts Úteis

### 9.1 Reinicialização completa do servidor

```bash
cat << 'EOF' > /opt/reboot-printserver.sh
#!/bin/bash
# Reboot do Print Server
reboot
EOF

chmod +x /opt/reboot-printserver.sh
```

### 9.2 Backup das configurações

```bash
cat << 'EOF' > /opt/backup-config.sh
#!/bin/bash
# Backup das configurações do Print Server

BACKUP_DIR="/root/printserver-backup"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Criando backup..."

cp /etc/cups/cupsd.conf $BACKUP_DIR/cupsd.conf.$DATE
cp /etc/samba/smb.conf $BACKUP_DIR/smb.conf.$DATE
cp /etc/avahi/avahi-daemon.conf $BACKUP_DIR/avahi-daemon.conf.$DATE
cp /etc/ufw/user.rules $BACKUP_DIR/ufw.rules.$DATE

echo "Backup salvo em: $BACKUP_DIR"
ls -lh $BACKUP_DIR
EOF

chmod +x /opt/backup-config.sh
```

### 9.3 Reinstalar drivers (caso precise)

```bash
cat << 'EOF' > /opt/reinstall-drivers.sh
#!/bin/bash
# Reinstalar drivers de impressora

apt install --reinstall -y \
    printer-driver-gutenprint \
    printer-driver-all \
    hplip \
    printer-driver-zj-58 \
    printer-driver-brlaser \
    printer-driver-foo2zjs \
    printer-driver-splix

systemctl restart cups

echo "Drivers reinstalados!"
EOF

chmod +x /opt/reinstall-drivers.sh
```

### 9.4 Verificar log de erros

```bash
cat << 'EOF' > /opt/tail-logs.sh
#!/bin/bash
# Monitorar logs em tempo real
tail -f /var/log/cups/error_log /var/log/samba/log.smbd /var/log/syslog | grep -i -E "(cups|samba|printer|error|warn)"
EOF

chmod +x /opt/tail-logs.sh
```

* * *

## Resumo — Comandos principais

| Ação | Comando |
| --- | --- |
| Ver status | `/opt/status.sh` |
| Reiniciar serviços | `/opt/restart-services.sh` |
| Ver logs em tempo real | `/opt/tail-logs.sh` |
| Fazer backup | `/opt/backup-config.sh` |
| Reiniciar servidor | `/opt/reboot-printserver.sh` |
| Acessar CUPS | `http://IP-DO-SERVIDOR:631` |

* * *

## Dicas Extras

### Impressoras HP — configuração automática

```bash
hp-setup -i
```

### Ver impressoras na rede via linha de comando

```bash
lpinfo -v          # Dispositivos disponíveis
lpinfo --make-and-model "HP" -m  # Drivers HP disponíveis
```

### Reiniciar só o CUPS (após adicionar impressora)

```bash
systemctl restart cups
```

### Ver fila de impressão

```bash
lpq
# ou
lpstat -o
```

### Cancelar impressão

```bash
lprm -P nome_da_impressora ALL
# ou
cancel -a
```

* * *

## Solução de Problemas

### Impressora não aparece na rede

```bash
# Verificar se Avahi está rodando
systemctl status avahi-daemon

# Ver dispositivos发现的
avahi-browse -rt _ipp._tcp
```

### Windows não vê as impressoras

```bash
# Verificar Samba
systemctl status smbd

# Testar configuração do Samba
testparm -s
```

### CUPS não responde

```bash
# Ver logs
tail -50 /var/log/cups/error_log

# Verificar se está escutando na porta
ss -tlnp | grep 631
```