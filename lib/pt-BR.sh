# lib/pt-BR.sh — Portuguese (Brazil) catalog
# Overrides the English base.

# common
MSG_ROOT_ERR="Rode como root (sudo -i)."

# bootstrap
MSG_BOOT_UPDATE="[0/4] Atualizando lista de pacotes..."
MSG_BOOT_GIT="[1/4] Instalando git..."
MSG_BOOT_DOWNLOAD="[2/4] Baixando o repo do printserver... (pode pedir suas credenciais do GitHub)"
MSG_BOOT_RUN="[3/4] Rodando instalador..."
MSG_BOOT_FW="[4/4] Configurando firewall..."
MSG_BOOT_DONE="Pronto! Veja o status:"
MSG_BOOT_MANUAL="O que ainda é manual (veja README):"
MSG_BOOT_MANUAL_1="  1. Adicionar impressoras pela interface web do CUPS: http://localhost:631"
MSG_BOOT_MANUAL_2="  2. HP: hp-setup -i | Brother: baixar .deb do site | Zebra/genérica: ps-add-raw-printer"

# install
MSG_INST_TITLE="  Print Server - Instalação"
MSG_INST_STEP1="[1/6] Atualizando sistema..."
MSG_INST_STEP2="[2/6] Instalando CUPS e dependências..."
MSG_INST_STEP3="[3/6] Instalando drivers de impressora..."
MSG_INST_STEP4="[4/6] Instalando Avahi..."
MSG_INST_STEP5="[5/6] Instalando Samba..."
MSG_INST_STEP6="[6/6] Instalando UFW..."
MSG_INST_ENABLE="Habilitando serviços..."
MSG_INST_SHORTCUTS="Atalhos criados: ps-status ps-check ps-logs ps-restart ps-backup ps-firewall ps-add-raw-printer ps-wifi ps-ip ps-update"
MSG_INST_DONE="  Instalação concluída!"
MSG_INST_CUPS_URL="CUPS:  http://localhost:631  (ou http://IP-DO-SERVIDOR:631)"
MSG_INST_FIRMWARE="Firmware de alguns modelos foo2zjs pode precisar de 'getweb' - veja README."
MSG_INST_ADMIN_MISSING="Usuário 'admin' não encontrado."
MSG_INST_ADMIN_PROMPT="Usuário para dar admin do CUPS (não use root): "
MSG_INST_ADMIN_ADDED="Usuário '%s' adicionado ao grupo lpadmin."
MSG_INST_ADMIN_ERR="! Usuário '%s' não existe. Crie-o ou rode: usermod -aG lpadmin <usuario>"

# firewall
MSG_FW_CONFIG="Configurando Firewall..."
MSG_FW_STATUS="Status do Firewall:"
MSG_FW_DONE="Firewall configurado!"

# wifi
MSG_WIFI_NM="Instalando NetworkManager..."
MSG_WIFI_NODEV="Nenhuma interface WiFi detectada:"
MSG_WIFI_SCAN="Procurando redes WiFi..."
MSG_WIFI_NONE="Nenhuma rede encontrada. Confira se a antena está habilitada ou aproxime-se do roteador."
MSG_WIFI_CHOOSE="Digite o número da rede: "
MSG_WIFI_INVALID="Opção inválida."
MSG_WIFI_PASS="Senha do WiFi: "
MSG_WIFI_CONNECT="Conectando em '%s'..."
MSG_WIFI_OK="Conectado a '%s'!"

# ip
MSG_IP_NOROUTE="Nenhuma rota default ativa. Conecte o cabo ou use ps-wifi primeiro."
MSG_IP_NOADDR="Sem IP em %s."
MSG_IP_NMCONN="Conexão NetworkManager ativa não identificada."
MSG_IP_WIFIIFACE="Interface WiFi: %s (conexão '%s')"
MSG_IP_MAC="MAC: %s  <- use em reserva DHCP no roteador"
MSG_IP_PROMPT_IP="IP fixo (ex: %s)"
MSG_IP_PROMPT_GW="Gateway"
MSG_IP_PROMPT_DNS="DNS (separados por espaço)"
MSG_IP_PROMPT_MASK="Máscara (ex: 255.255.255.0)"
MSG_IP_APPLY_NM="Aplicando via NetworkManager..."
MSG_IP_RECONNECT="Reconectando (a sessão SSH cai por segundos)..."
MSG_IP_NEWIP="Novo IP: %s"
MSG_IP_HINT="Dica: reserve a MAC no roteador para evitar este passo no futuro."
MSG_IP_ETHIFACE="Interface Ethernet: %s"
MSG_IP_WRITE="Gravando /etc/network/interfaces..."
MSG_IP_APPLY_HOT="Aplicando sem derrubar a sessão..."
MSG_IP_REBOOT_HINT="Depois de um reboot a configuração fica definitiva."

# status
MSG_STATUS_HEADER="  Print Server - Status"
MSG_STATUS_CUPS=">>> CUPS:"
MSG_STATUS_BROWSED=">>> cups-browsed (descobre impressoras de rede):"
MSG_STATUS_AVAHI=">>> Avahi:"
MSG_STATUS_SAMBA=">>> Samba:"
MSG_STATUS_FW=">>> Firewall:"
MSG_STATUS_PRINTERS=">>> Impressoras configuradas:"
MSG_STATUS_NONE="   Nenhuma configurada"
MSG_STATUS_QUEUE=">>> Fila:"
MSG_STATUS_QUEUE_EMPTY="   Fila vazia"
MSG_STATUS_NET=">>> Rede:"
MSG_STATUS_ACTIVE="   Ativo"
MSG_STATUS_INACTIVE="   INATIVO"

# check
MSG_CHECK_DEVICES="=== Dispositivos de impressão detectados ==="
MSG_CHECK_PORTS="=== Portas em escuta ==="
MSG_CHECK_NOTHING="nada escutando"
MSG_CHECK_AVAHI="=== Impressoras de rede via Avahi (IPP) ==="
MSG_CHECK_AVAHI_NA="avahi-browse indisponível"
MSG_CHECK_SAMBA="=== Config do Samba (teste) ==="
MSG_CHECK_LOG="=== Log de erros do CUPS (últimas 30 linhas) ==="

# backup
MSG_BACKUP_SAVED="Backup salvo em: %s"

# update
MSG_UPDATE_NOREPO="Repositório não encontrado em /opt/printserver."
MSG_UPDATE_FIRST="Instale primeiro com o one-liner do bootstrap."
MSG_UPDATE_PULL="Buscando atualizações..."
MSG_UPDATE_APPLY="Aplicando configs novamente..."

# add-raw-printer
MSG_RAW_PERM="Rode como root ou como usuário do grupo lpadmin."
MSG_RAW_USAGE="Uso: %s <nome> <ip> [porta]"
MSG_RAW_ADDED="Impressora '%s' -> socket://%s:%s (raw) adicionada."
MSG_RAW_SEND="Envie ZPL/Esc-POS direto:"
MSG_RAW_EXAMPLE="  lpr -P %s arquivo.zpl   (ou  nc %s %s < arquivo.zpl)"