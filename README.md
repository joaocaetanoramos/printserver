# Print Server — Debian + CUPS (leve, sem interface)

Servidor de impressão headless: CUPS (IPP), Avahi (descoberta), Samba (Windows legado) e UFW.
Tudo instalado via **um comando**. O que não dá pra automatizar fica aqui embaixo.

---

## Como funciona

O script `scripts/bootstrap.sh` faz tudo: instala pacotes, escreve as configs, sobe os
serviços e configura o firewall. Depois só falta **adicionar as impressoras reais**.

---

## 1. Instalar o Debian (manual, uma vez)

1. Baixe o netinst: https://www.debian.org/distrib/netinst
2. Grave num pendrive (Rufus no Windows / `dd` no Linux).
3. Instale com as recomendações:

| Passo | Recomendação |
|---|---|
| Idioma | Portuguese (Brazil) |
| Rede | Ethernet (DHCP) |
| Hostname | `printserver` |
| Usuário | `admin` (importante: será o admin do CUPS) |
| Disco | Guiado, disco inteiro |
| Seleção de software | **NÃO marcar nada** |

4. Após reiniciar, defina o **IP fixo** (ajuste à sua rede):

```bash
# veja o nome da interface
ip a
nano /etc/network/interfaces
```

```conf
auto enp0s3
iface enp0s3 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

```bash
systemctl restart networking
```

> ⚠️ Se você está logado por SSH, reiniciar a rede derruba a sessão. Pode usar `reboot` também.

---

## 2. Instalar o servidor (automático, 1 comando)

Como root no servidor:

```bash
sudo -i
wget -qO- https://raw.githubusercontent.com/joaocaetanoramos/printserver/main/scripts/bootstrap.sh | bash
```

Isso:
- instala CUPS, drivers (HP, Epson, Brother laser, termal, genéricas), Avahi, Samba, UFW;
- copia scripts de operação para `/opt/printserver`;
- adiciona o usuário no grupo `lpadmin`;
- libera a porta 631 (CUPS), 9100 (raw), 5353 (Avahi) e Samba no firewall;
- habilita e inicia os serviços.

---

## 3. Adicionar as impressoras (manual, depende de cada modelo)

Depois da instalação, tudo é feito pela interface web do CUPS:
**http://IP-DO-SERVIDOR:631** → Administration → Add Printer (usar o usuário `admin`).

### Por tipo de impressora

| Tipo | Como configurar |
|---|---|
| **USB** | Plugue no servidor → Add Printer → aparece na lista → escolhe o driver |
| **Rede (IPP/Network)** | Add Printer → "IPP / Network Printer" ou discovery automático |
| **HP** | `hp-setup -i` (detecta USB/rede e instala driver) |
| **Epson** | Gerenciada automaticamente pelo `printer-driver-escpr`/gutenprint |
| **Brother laser** | Driver `brlaser` já coberto; jato de tinta Brother: baixar `.deb` do site da Brother e `dpkg -i` |
| **Zebra / termal / genérica "china"** | Não precisa de driver. **USB:** plugue no servidor → Add Printer → escolha o dispositivo USB → driver **"Raw"** (em "Generic") → pronto. **Rede:** fila raw na porta 9100 com o script: |

```bash
ps-add-raw-printer zebra-100 192.168.1.150
```

Depois é só mandar o arquivo (funciona em ambas, USB e rede):

```bash
lpr -P zebra-100 etiqueta.zpl        # ZPL
nc 192.168.1.150 9100 < etiqueta.zpl # direto na rede
```

Cada impressora termal tem um comando (ZPL, EPL, Esc/POS...). Sem driver, o jeito é raw: você
manda o comando/snprintf diretamente.

### Testar

```bash
# imprimir página de teste
lp -d nome_da_impressora /etc/hostname  # texto qualquer

# status da fila
lpq
lpstat -p -d
```

---

## Comandos úteis (atalhos `ps-*` em `/usr/local/bin`)

| Ação | Comando |
|---|---|
| Status geral | `ps-status` |
| Diagnóstico completo | `ps-check` |
| Reiniciar serviços | `ps-restart` |
| Logs em tempo real | `ps-logs` |
| Backup de configs | `ps-backup` |
| Firewall | `ps-firewall` |
| Impressora raw (Zebra/genérica) | `ps-add-raw-printer nome ip` |
| Ferramentas de impressora | `lpinfo -v`, `lpstat -p`, `lpq`, `cancel -a` |

---

## Solução de problemas

### Impressora não aparece na rede
```bash
systemctl status avahi-daemon
avahi-browse -rt _ipp._tcp        # quem está anunciando IPP na rede
```

### CUPS não responde
```bash
ss -tlnp | grep 631               # está escutando?
tail -50 /var/log/cups/error_log
```

### Windows não instala via Samba (legado)
```bash
testparm -s                       # valida o smb.conf
systemctl status smbd
```
Preferir instalação por IPP no Windows (Adicionar impressora → "IP ou hostname" →
`http://IP-DO-SERVIDOR:631/printers/NOME_DA_IMPRESSORA`). É mais moderno que Samba.

### Driver foo2zjs precisa de firmware (genéricas Samsung/Xerox)
O pacote instala o driver; a firmware extra é baixada de site externo quando o modelo exige:
```bash
sudo /usr/share/doc/printer-driver-foo2zjs/getweb <modelo>
```

---

## O que fica manual (resumo)

- Instalar o Debian + definir IP fixo (rede de cada um).
- Adicionar as impressoras reais (depende do modelo/firmware — seção 3 acima).
- HP: rodar `hp-setup -i`.
- Brother jato de tinta: baixar driver do site da Brother.
- Zebra/termal/genérica: fila raw via `add-raw-printer.sh` (nenhum driver necessário).

Repositório: https://github.com/joaocaetanoramos/printserver (público)
Guia original (sem as correções): `docs/guia-original.md`